import '../utils/mappable.dart';

class Category implements Mappable{
  final String id;
  final String accountId;
  final String name;
  final String type; // "income" or "expense"
  final String iconPath; // Optional: For custom icons
  final String creatorId;  // ID of the user who created the category

  Category({
    required this.id,
    required this.accountId,
    required this.name,
    required this.type,
    this.iconPath = '',
    required this.creatorId,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'name': name,
      'type': type,
      'iconPath': iconPath,
      'creatorId': creatorId,
    };
  }

  static Category fromMap(Map<String, dynamic> map, String documentId) {
    return Category(
      id: documentId,
      accountId: map['accountId'],
      name: map['name'],
      type: map['type'],
      iconPath: map['iconPath'] ?? '',
      creatorId: map['creatorId'],
    );
  }
}