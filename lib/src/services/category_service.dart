import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgeting_saving_app/src/models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch categories
  Future<List<Category>> fetchCategories({String? type}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('categories');
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      final QuerySnapshot<Map<String, dynamic>> categorySnapshot = await query.get();

      return categorySnapshot.docs
          .map((doc) => Category.fromMap(doc.data()!, doc.id))
          .toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  // Add a new category
  Future<void> addCategory(Category category) async {
    try {
      print("Adding category: ${category.name}");
      await _firestore.collection('categories').add(category.toMap());
      print("Category added successfully");
    } catch (e) {
      print("Error adding category: $e");
      // Handle the error appropriately
    }
  }

  // Update an existing category
  Future<void> updateCategory(Category category) async {
    await _firestore.collection('categories').doc(category.id).update(category.toMap());
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }
}
