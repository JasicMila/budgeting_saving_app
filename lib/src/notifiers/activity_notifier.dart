
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import 'package:budgeting_saving_app/src/providers/providers.dart';
import '../services/currency_service.dart';
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
      } else {
        // Fetch all accessible accounts for the user
        var accounts = await ref.read(accountNotifierProvider.notifier).fetchAccounts();
        var userAccountIds = accounts.map((account) => account.id).toList();

        // Filter activities by accessible accounts
        activities = activities.where((activity) => userAccountIds.contains(activity.accountId)).toList();
      }
      state = activities;
    } catch (e, stackTrace) {
      print("Error fetching activities: $e");
      print("Stack trace: $stackTrace");
    }
  }


  Future<void> addActivity(Activity activity) async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      final mainCurrency = ref.read(accountNotifierProvider.notifier).mainCurrency;
      if (mainCurrency != null && activity.currency != mainCurrency) {
        final convertedAmount = await CurrencyService.convert(activity.amount, activity.currency, mainCurrency);
        activity = activity.copyWith(
          amount: convertedAmount,
          currency: mainCurrency,
          originalAmount: activity.amount,
          originalCurrency: activity.currency,
        );
      } else {
        activity = activity.copyWith(
          originalAmount: activity.amount,
          originalCurrency: activity.currency,
        );
      }

      final newActivity = activity.copyWith(creatorId: user.uid, userIds: [user.uid]);
      await _firestoreService.create(newActivity.toMap(), newActivity.id, user.uid);
      await _updateAccountBalance(newActivity.accountId, newActivity.amount, newActivity.type);
      state = [...state, newActivity];
    } catch (e, stackTrace) {
      print("Error adding activity: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> removeActivity(String activityId) async {
    try {
      final activity = state.firstWhere((activity) => activity.id == activityId);
      await _firestoreService.delete(activityId);
      await _updateAccountBalance(activity.accountId, -activity.amount, activity.type);
      state = state.where((activity) => activity.id != activityId).toList();
    } catch (e, stackTrace) {
      print("Error removing activity: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> updateActivity(String activityId, Activity updatedActivity) async {
    try {
      final oldActivity = state.firstWhere((activity) => activity.id == activityId);

      final mainCurrency = ref.read(accountNotifierProvider.notifier).mainCurrency;
      if (mainCurrency != null && updatedActivity.currency != mainCurrency) {
        final convertedAmount = await CurrencyService.convert(updatedActivity.amount, updatedActivity.currency, mainCurrency);
        updatedActivity = updatedActivity.copyWith(
          amount: convertedAmount,
          currency: mainCurrency,
          originalAmount: updatedActivity.amount,
          originalCurrency: updatedActivity.currency,
        );
      } else {
        updatedActivity = updatedActivity.copyWith(
          originalAmount: updatedActivity.amount,
          originalCurrency: updatedActivity.currency,
        );
      }

      await _firestoreService.update(activityId, updatedActivity.toMap());
      await _updateAccountBalance(oldActivity.accountId, -oldActivity.amount, oldActivity.type);
      await _updateAccountBalance(updatedActivity.accountId, updatedActivity.amount, updatedActivity.type);
      state = state.map((activity) => activity.id == activityId ? updatedActivity : activity).toList();
    } catch (e, stackTrace) {
      print("Error updating activity: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> _updateAccountBalance(String accountId, double amount, ActivityType type) async {
    try {
      final accountNotifier = ref.read(accountNotifierProvider.notifier);
      final account = ref.read(accountNotifierProvider).firstWhere((acc) => acc.id == accountId);

      final updatedBalance = type == ActivityType.income
          ? account.balance + amount
          : account.balance - amount;

      final updatedAccount = account.copyWith(balance: updatedBalance);
      await accountNotifier.updateAccount(updatedAccount);
    } catch (e, stackTrace) {
      print("Error updating account balance: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> convertActivityAmounts() async {
    try {
      final mainCurrency = ref.read(accountNotifierProvider.notifier).mainCurrency;
      if (mainCurrency == null) return;

      state = await Future.wait(state.map((activity) async {
        if (activity.originalCurrency != mainCurrency) {
          final newAmount = await CurrencyService.convert(activity.originalAmount, activity.originalCurrency, mainCurrency);
          return activity.copyWith(amount: newAmount, currency: mainCurrency);
        }
        return activity;
      }));

      await Future.wait(state.map((activity) => _firestoreService.update(activity.id, activity.toMap())));
    } catch (e, stackTrace) {
      print("Error converting activity amounts: $e");
      print("Stack trace: $stackTrace");
    }
  }


  void clearActivities() {
    state = [];
  }
}
