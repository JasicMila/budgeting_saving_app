
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/activity.dart';
import 'package:budgeting_saving_app/src/providers/providers.dart';
import '../services/currency_service.dart';
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

  Future<List<Account>> fetchAccounts() async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) {
        state = [];
        return [];
      }

      var accounts = await _firestoreService.fetchAll(user.uid);
      state = accounts;
      return accounts;
    } catch (e, stackTrace) {
      print("Error fetching accounts: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      // Check if account name is unique
      if (!await _firestoreService.isAccountNameUnique(account.name)) {
        throw Exception('Account name must be unique');
      }

      final newAccount = account.copyWith(creatorId: user.uid);
      await _firestoreService.create(newAccount.toMap(), newAccount.id, user.uid);


      // Initialize default categories
      for (var category in defaultCategories) {
        final newCategory = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          accountId: newAccount.id,
          name: category['name'] ?? '',
          type: category['type'] ?? '',
          creatorId: newAccount.creatorId,
          userIds: [user.uid],
        );
        await _categoryService.create(newCategory.toMap(), newCategory.id, user.uid);
      }

      state = [...state, newAccount];
    } catch (e, stackTrace) {
      print("Failed to add account: $e");
      print("Stack trace: $stackTrace");
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

      // Delete account
      await _firestoreService.delete(accountId);
      state = state.where((account) => account.id != accountId).toList();
    } catch (e, stackTrace) {
      print("Error removing account: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> updateAccount(Account updatedAccount) async {
    try {
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      // Check if account name is unique, excluding the current account ID
      if (!await _firestoreService.isAccountNameUnique(updatedAccount.name, updatedAccount.id)) {
        throw Exception('Account name must be unique');
      }

      await _firestoreService.update(updatedAccount.id, updatedAccount.toMap());
      state = state.map((account) => account.id == updatedAccount.id ? updatedAccount : account).toList();
    } catch (e, stackTrace) {
      print("Error updating account: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> setMainAccount(String accountId) async {
    try {
      state = state.map((account) => account.copyWith(isMainAccount: account.id == accountId)).toList();
      await Future.wait(state.map((account) => _firestoreService.update(account.id, account.toMap())));
    } catch (e, stackTrace) {
      print("Error setting main account: $e");
      print("Stack trace: $stackTrace");
    }
  }

  String? get mainCurrency => state.firstWhere((account) => account.isMainAccount, orElse: () => state.first).currency;

  Future<void> convertAccountBalances() async {
    try {
      final mainCurr = mainCurrency;
      if (mainCurr == null) return;

      final rates = await CurrencyService.getExchangeRates(mainCurr);
      state = await Future.wait(state.map((account) async {
        if (account.currency != mainCurr) {
          final newBalance = await CurrencyService.convert(account.balance, account.currency, mainCurr);
          return account.copyWith(balance: newBalance, currency: mainCurr);
        }
        return account;
      }));

      await Future.wait(state.map((account) => _firestoreService.update(account.id, account.toMap())));
    } catch (e, stackTrace) {
      print("Error converting account balances: $e");
      print("Stack trace: $stackTrace");
    }
  }

  void clearAccounts() {
    state = [];
  }
}

