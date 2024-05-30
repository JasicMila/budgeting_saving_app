import 'account.dart';

class User {
  final String id;
  final String name;
  final String email;
  final List<Account> accounts;
  final String preferredCurrency;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.accounts,
    required this.preferredCurrency,
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'],
      email: map['email'],
      accounts: (map['accounts'] as List).map((account) => Account.fromMap(account, account['id'])).toList(),
      preferredCurrency: map['preferredCurrency'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'accounts': accounts.map((account) => account.toMap()).toList(),
      'preferredCurrency': preferredCurrency,
    };
  }
}