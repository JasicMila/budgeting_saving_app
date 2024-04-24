import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String accountId;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final DateTime date;

  Activity({
    this.id = '',
    required this.accountId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
    };
  }

  static Activity fromMap(Map<String, dynamic> map, String documentId) {
    return Activity(
      id: documentId,
      accountId: map['accountId'],
      amount: map['amount'].toDouble(),
      type: map['type'],
      category: map['category'],
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
