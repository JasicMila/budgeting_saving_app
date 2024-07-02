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
  final List<String> userIds;
  final double originalAmount;
  final String originalCurrency;

  Activity({
    required this.id,
    required this.accountId,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    required this.creatorId,
    required this.userIds,
    required this.originalAmount,
    required this.originalCurrency,
  });

  // Serialization
  factory Activity.fromMap(Map<String, dynamic> map, String id) {
    return Activity(
      id: id,
      accountId: map['accountId'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      type: ActivityType.values.firstWhere(
            (e) => e.toString() == 'ActivityType.${map['type'] ?? 'expense'}',
        orElse: () => ActivityType.expense,
      ),
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'EUR',
      creatorId: map['creatorId'] ?? '',
      userIds: List<String>.from(map['userIds'] ?? []),
      originalAmount: (map['originalAmount'] ?? 0).toDouble(),
      originalCurrency: map['originalCurrency'] ?? 'EUR',
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
      'userIds': userIds,
      'originalAmount': originalAmount,
      'originalCurrency': originalCurrency,
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
    List<String>? userIds,
    double? originalAmount,
    String? originalCurrency,
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
      userIds: userIds ?? this.userIds,
      originalAmount: originalAmount ?? this.originalAmount,
      originalCurrency: originalCurrency ?? this.originalCurrency,
    );
  }
}


