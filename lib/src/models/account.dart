import 'package:budgeting_saving_app/src/utils/mappable.dart';

class Account implements Mappable {
  final String id;
  final String name;
  final String currency;
  late final double balance;
  final String creatorId;
  final List<String> userIds; // IDs of users who can access this account

  Account({
    required this.id,
    required this.name,
    required this.currency,
    required this.balance,
    required this.creatorId,
    required this.userIds
  });

  Account copyWith({
    String? id,
    String? name,
    String? currency,
    double? balance,
    String? creatorId,
    List<String>? userIds,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      creatorId: creatorId ?? this.creatorId,
      userIds: userIds ?? this.userIds,
    );
  }

  // Serialization
  factory Account.fromMap(Map<String, dynamic> map, String id) {
    return Account(
      id: id,
      name: map['name'],
      currency: map['currency'],
      balance: map['balance'].toDouble(),
      creatorId: map['creatorId'],
      userIds: List<String>.from(map['userIds']),
    );
  }

  // Deserialization
  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'currency': currency,
      'balance': balance,
      'creatorId': creatorId,
      'userIds': userIds,
    };
  }
}

