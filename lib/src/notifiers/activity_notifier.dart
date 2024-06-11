
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import 'package:budgeting_saving_app/src/providers/providers.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class ActivityNotifier extends StateNotifier<List<Activity>> {
  final Ref ref;
  FirestoreService<Activity> get _firestoreService => ref.read(firestoreActivityServiceProvider);

  ActivityNotifier(this.ref) : super([]) {
    fetchActivities();  // Fetch all activities when the notifier is initialized
  }

  Future<void> fetchActivities([String? accountId]) async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) {
        state = [];
        return;
      }

      var activities = await _firestoreService.fetchAll(user.uid);
      // If accountId is provided, filter activities by that accountId.
      if (accountId != null && accountId.isNotEmpty) {
        activities = activities.where((activity) => activity.accountId == accountId).toList();
      }else {
        // Fetch all accessible accounts for the user
        var accounts = await ref.read(accountNotifierProvider.notifier).fetchAccounts();
        var userAccountIds = accounts.map((account) => account.id).toList();

        // Filter activities by accessible accounts
        activities = activities.where((activity) => userAccountIds.contains(activity.accountId)).toList();
      }
      state = activities;
    } catch (e) {
      print("Error fetching activities: $e");
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      final newActivity = activity.copyWith(creatorId: user.uid);
      await _firestoreService.create(newActivity.toMap(), newActivity.id, user.uid);
      await _updateAccountBalance(newActivity.accountId, newActivity.amount, newActivity.type);
      state = [...state, newActivity];
    } catch (e) {
      print("Error adding activity: $e");
    }
  }

  Future<void> removeActivity(String activityId) async {
    try {
      final activity = state.firstWhere((activity) => activity.id == activityId);
      await _firestoreService.delete(activityId);
      await _updateAccountBalance(activity.accountId, -activity.amount, activity.type);
      state = state.where((activity) => activity.id != activityId).toList();
    } catch (e) {
      print("Error removing activity: $e");
    }
  }

  Future<void> updateActivity(String activityId, Activity updatedActivity) async {
    try {
      final oldActivity = state.firstWhere((activity) => activity.id == activityId);
      await _firestoreService.update(activityId, updatedActivity.toMap());
      await _updateAccountBalance(oldActivity.accountId, -oldActivity.amount, oldActivity.type);
      await _updateAccountBalance(updatedActivity.accountId, updatedActivity.amount, updatedActivity.type);
      state = state.map((activity) => activity.id == activityId ? updatedActivity : activity).toList();
    } catch (e) {
      print("Error updating activity: $e");
    }
  }

  Future<void> _updateAccountBalance(String accountId, double amount, ActivityType type) async {
    final accountNotifier = ref.read(accountNotifierProvider.notifier);
    final account = ref.read(accountNotifierProvider).firstWhere((acc) => acc.id == accountId);

    final updatedBalance = type == ActivityType.income
        ? account.balance + amount
        : account.balance - amount;

    final updatedAccount = account.copyWith(balance: updatedBalance);
    await accountNotifier.updateAccount(updatedAccount);
  }

  void clearActivities() {
    state = [];
  }
}
