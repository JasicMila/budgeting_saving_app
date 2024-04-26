
import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String userId;
  final String accountId;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final DateTime date;
  final String currency;

  Activity({
    this.id = '',
    required this.accountId,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.currency = 'EUR',
  });

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'userId': userId,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'currency': currency,
    };
  }

  static Activity fromMap(Map<String, dynamic> map, String documentId) {
    return Activity(
      id: documentId,
      userId: map['userId'],
      accountId: map['accountId'],
      amount: map['amount'].toDouble(),
      type: map['type'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      currency: map['currency'],
    );
  }
}
