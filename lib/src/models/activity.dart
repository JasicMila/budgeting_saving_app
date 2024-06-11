import 'package:budgeting_saving_app/src/utils/constants.dart';
import 'package:budgeting_saving_app/src/utils/mappable.dart';

class Activity implements Mappable {
  final String id;
  final String accountId;
  final DateTime date;
  final ActivityType type; // enum 'income' or 'expense'
  final String category;
  final double amount;
  final String currency;
  final String creatorId; // ID of the user who created the activity

  Activity({
    required this.id,
    required this.accountId,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    required this.creatorId,
  });

  // Serialization
  factory Activity.fromMap(Map<String, dynamic> map, String id) {
    return Activity(
      id: id,
      accountId: map['accountId'],
      date: DateTime.parse(map['date']),
      type: ActivityType.values.firstWhere((e) => e.toString().split('.').last == map['type']),
      category: map['category'],
      amount: map['amount'].toDouble(),
      currency: map['currency'],
      creatorId: map['creatorId'],
    );
  }

  // Deserialization
  @override
  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last, // Converting enum to string for storage
      'category': category,
      'amount': amount,
      'currency': currency,
      'creatorId': creatorId,
    };
  }

  // CopyWith method
  Activity copyWith({
    String? id,
    String? accountId,
    DateTime? date,
    ActivityType? type,
    String? category,
    double? amount,
    String? currency,
    String? creatorId,
  }) {
    return Activity(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      creatorId: creatorId ?? this.creatorId,
    );
  }
}


