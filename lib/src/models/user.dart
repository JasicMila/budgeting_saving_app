import 'account.dart';

class User {
  final String id;
  final String name;
  final String email; // Optional, for future authentication
  final List<Account> accounts;
  final String preferredCurrency;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.accounts,
    required this.preferredCurrency,
  });

// Optional: Conversion methods, account management methods
}
