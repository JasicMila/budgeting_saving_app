import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budgeting_saving_app/src/models/category.dart'
    as category_model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class CategoryService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<category_model.Category> _categories = [];

  CategoryService() {
    fetchCategories();
  }

  List<category_model.Category> get categories => _categories;

  // Fetch categories
  Future<void> fetchCategories({String? type}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('categories')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid);
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      final QuerySnapshot<Map<String, dynamic>> categorySnapshot =
          await query.get();

      _categories = categorySnapshot.docs
          .map((doc) => category_model.Category.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  // Add a new category
  Future<void> addCategory(category_model.Category category) async {
    try {
      print("Adding category: ${category.name}");
      await _firestore.collection('categories').add(category.toMap());
      _categories.add(category);
      notifyListeners();
      print("Category added successfully");
    } catch (e) {
      print("Error adding category: $e");
      // Handle the error appropriately
    }
  }

  // Update an existing category
  Future<void> updateCategory(category_model.Category category) async {
    try {
      if (category.id.isEmpty) {
        throw Exception("Category ID cannot be empty");
      }
      print("Updating category: ${category.name}");
      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(category.toMap());
      int index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
      print("Category updated successfully");
    } catch (e) {
      print("Error updating category: $e");
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
    } catch (e) {
      print("Error deleting category: $e");
    }
  }
}
