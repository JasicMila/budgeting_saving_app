import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgeting_saving_app/src/models/account.dart';

class AccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Account>> fetchAccounts() async {
    try {
      final QuerySnapshot accountSnapshot = await _firestore
          .collection('accounts')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      final List<Account> accounts = accountSnapshot.docs
          .map((doc) =>
              Account.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return accounts;
    } catch (e) {
      // Log the error for debugging purposes
      print("Error fetching accounts: $e");
      return [];
    }
  }

  Future<Map<String, String>> fetchAccountNames() async {
    Map<String, String> accountNames = {};
    try {
      final result = await _firestore
          .collection('accounts')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      for (var doc in result.docs) {
        final account = Account.fromMap(doc.data(), doc.id);
        accountNames[account.id] = account.name;
      }
    } catch (e) {
      print("Error fetching account names: $e");
    }
    return accountNames;
  }
}
