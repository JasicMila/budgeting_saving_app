class Transaction {
  final String id;
  final String accountId; // Link to an Account
  final String categoryId; // Link to a Category
  final double amount;
  final String currency; // ISO currency code
  final DateTime date;
  final String type; // "income" or "expense"

  Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.currency,
    required this.date,
    required this.type,
  });

// Optional: Conversion methods, etc.?
}
