import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgeting_saving_app/src/models/account.dart';

class AccountService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Account> _accounts = [];
  bool _isLoading = false;

  AccountService(){
    fetchAccounts();
  }

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  Future<void> fetchAccounts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final QuerySnapshot accountSnapshot = await _firestore
          .collection('accounts')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      _accounts = accountSnapshot.docs
          .map((doc) => Account.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();  // Notify widgets of state change
    } catch (e) {
      // Handle exceptions by logging or re-throwing
      print("Error fetching accounts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new account
  Future<void> addAccount(Account account) async {
    try {
      print("Adding account: ${account.name}");
      await _firestore.collection('accounts').add(account.toMap());
      _accounts.add(account);
      notifyListeners();
      print("account added successfully");
    } catch (e) {
      print("Error adding account: $e");
    }
  }
  // Update an existing account
  Future<void> updateAccount(Account account) async {
    try {
      print("Editing account: ${account.name}");
      await _firestore.collection('accounts').doc(account.id).update(account.toMap());
      int index = _accounts.indexWhere((acc) => acc.id == account.id);
      if (index != -1) {
        _accounts[index] = account;
        notifyListeners();
      }
      print("account edited successfully");
    } catch (e) {
      print("Error editing account: $e");
    }
  }
  // Delete an account
  Future<void> deleteAccount(String accountId) async {
    try {
      print("Deleting account: $accountId");
      await _firestore.collection('accounts').doc(accountId).delete();
      _accounts.removeWhere((acc) => acc.id == accountId);
      notifyListeners();
      print("account deleted successfully");
    } catch (e) {
      print("Error deleting account: $e");
    }

  }
}
