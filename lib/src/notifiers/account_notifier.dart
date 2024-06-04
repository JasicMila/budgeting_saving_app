
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/activity.dart';
import '../providers/firestore_service_provider.dart';
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
      var accounts = await _firestoreService.fetchAll();
      state = accounts.cast<Account>();
    } catch (e) {
      print("Error fetching accounts: $e");
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      print("Adding account: ${account.toMap()}");
      await _firestoreService.create(account.toMap(), account.id);

      // Initialize default categories
      for (var category in defaultCategories) {
        final newCategory = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          accountId: account.id,
          name: category['name'],
          type: category['type'],
          creatorId: account.creatorId,
        );
        await _categoryService.create(newCategory.toMap(), newCategory.id);
      }

      state = [...state, account];
    } catch (e) {
      print("Failed to add account: $e");
    }
  }

  Future<void> removeAccount(String accountId) async {
    try {
      // Fetch and delete all activities related to the account
      var activities = await _activityService.fetchAll();
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

