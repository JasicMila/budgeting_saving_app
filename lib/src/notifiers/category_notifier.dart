
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/firestore_service.dart';
import 'package:budgeting_saving_app/src/providers/providers.dart';
import 'package:collection/collection.dart';


class CategoryNotifier extends StateNotifier<List<Category>> {
  final Ref ref;
  final String accountId;

  FirestoreService<Category> get _firestoreService => ref.read(firestoreCategoryServiceProvider);

  CategoryNotifier(this.ref, this.accountId) : super([]) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      var categories = await _firestoreService.fetchAll();
      state = categories.where((category) => category.accountId == accountId).toList();
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> addCategory(Category category) async {
    if (FirebaseAuth.instance.currentUser?.uid == category.creatorId) {
      try {
        await _firestoreService.create(category.toMap(), category.id);
        state = [...state, category];
      } catch (e) {
        print("Error adding category: $e");
      }
    } else {
      print("Unauthorized to add categories");
    }
  }

  Future<void> removeCategory(String categoryId) async {
    var category = state.firstWhereOrNull((cat) => cat.id == categoryId);
    if (FirebaseAuth.instance.currentUser?.uid == category!.creatorId) {
      try {
        await _firestoreService.delete(categoryId);
        state = state.where((cat) => cat.id != categoryId).toList();
      } catch (e) {
        print("Error removing category: $e");
      }
    } else {
      print("Unauthorized to remove categories");
    }
  }

  Future<void> updateCategory(String categoryId, Category updatedCategory) async {
    var category = state.firstWhereOrNull((cat) => cat.id == categoryId);
    if (FirebaseAuth.instance.currentUser?.uid == category!.creatorId) {
      try {
        await _firestoreService.update(categoryId, updatedCategory.toMap());
        state = state.map((cat) => cat.id == categoryId ? updatedCategory : cat).toList();
      } catch (e) {
        print("Error updating category: $e");
      }
    } else {
      print("Unauthorized to update categories");
    }
  }
}
