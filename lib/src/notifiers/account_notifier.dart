
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/activity.dart';
import 'package:budgeting_saving_app/src/providers/providers.dart';
import '../services/firestore_service.dart';
import '../utils/default_categories.dart';

class AccountNotifier extends StateNotifier<List<Account>> {
  final Ref ref;
  FirestoreService<Account> get _firestoreService => ref.read(firestoreAccountServiceProvider);
  FirestoreService<Category> get _categoryService => ref.read(firestoreCategoryServiceProvider);
  FirestoreService<Activity> get _activityService => ref.read(firestoreActivityServiceProvider);

  AccountNotifier(this.ref) : super([]) {
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    try {

      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      var accounts = await _firestoreService.fetchAll(user.uid);
      state = accounts;
    } catch (e) {
      print("Error fetching accounts: $e");
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      final newAccount = account.copyWith(creatorId: user.uid);
      await _firestoreService.create(newAccount.toMap(), newAccount.id, user.uid);


      // Initialize default categories
      for (var category in defaultCategories) {
        final newCategory = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          accountId: newAccount.id,
          name: category['name'],
          type: category['type'],
          creatorId: newAccount.creatorId,
        );
        await _categoryService.create(newCategory.toMap(), newCategory.id, user.uid);
      }

      state = [...state, account];
    } catch (e) {
      print("Failed to add account: $e");
    }
  }

  Future<void> removeAccount(String accountId) async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      // Fetch and delete all activities related to the account
      var activities = await _activityService.fetchAll(user.uid);
      for (var activity in activities) {
        if (activity.accountId == accountId) {
          await _activityService.delete(activity.id);
        }
      }

      // Delete the account
      await _firestoreService.delete(accountId);
      state = state.where((account) => account.id != accountId).toList();
    } catch (e) {
      print("Error removing account: $e");
    }
  }

  Future<void> updateAccount(Account updatedAccount) async {
    try {
      print("Updating account: ${updatedAccount.toMap()}");
      await _firestoreService.update(updatedAccount.id, updatedAccount.toMap());
      state = state.map((account) => account.id == updatedAccount.id ? updatedAccount : account).toList();
    } catch (e) {
      print("Error updating account: $e");
    }
  }
}

