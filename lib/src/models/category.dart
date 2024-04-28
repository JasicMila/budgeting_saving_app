class Category {
  final String id;
  final String userId;
  final String name;
  final String type; // "income" or "expense"
  final String iconPath; // Optional: For custom icons

  Category({
    this.id = '',
    required this.userId,
    required this.name,
    required this.type,
    this.iconPath = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'iconPath': iconPath,
    };
  }

  static Category fromMap(Map<String, dynamic> map, String documentId) {
    return Category(
      id: documentId,
      userId: map['userId'],
      name: map['name'],
      type: map['type'],
      iconPath: map['iconPath'] ?? '',
    );
  }
}