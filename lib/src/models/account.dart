class Account {
  final String id;
  final String name;
  final String currency; // ISO currency code (e.g., USD, EUR)

  Account({required this.id, required this.name, required this.currency});

  // Method to convert Account to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
    };
  }

  // Method to create an Account from a map
  static Account fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      name: map['name'],
      currency: map['currency'],
    );
  }
}

// Conversion methods?
