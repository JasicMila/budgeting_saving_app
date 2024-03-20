class Account {
  final String id;
  final String name;
  final String currency; // ISO currency code (e.g., USD, EUR)
  final double amount; // Current account balance
  final String userId; // Add this line



  Account({
    this.id = '',
    required this.name,
    required this.currency,
    required this.amount,
    this.userId = '',
  });


  // Method to convert Account to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'currency': currency,
      'amount': amount,
      'userId': userId,
    };
  }

  // Method to create an Account from a map
  static Account fromMap(Map<String, dynamic> map, String documentId) {
    return Account(
      id: documentId,
      name: map['name'],
      currency: map['currency'],
      amount: map['amount']?.toDouble() ?? 0.0,
      userId: map['userId'],
    );
  }
}

// Conversion methods?
