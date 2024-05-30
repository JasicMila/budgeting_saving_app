// All Firestore providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/activity.dart';
import '../models/category.dart' as category_model;
import '../services/firestore_service.dart';

// Provider for FirestoreService handling Account
final firestoreAccountServiceProvider = Provider<FirestoreService<Account>>((ref) {
  return FirestoreService<Account>(
      'accounts',
          (data, documentId) => Account.fromMap(data, documentId)
  );
});

// Provider for FirestoreService handling Activity
final firestoreActivityServiceProvider = Provider<FirestoreService<Activity>>((ref) {
  return FirestoreService<Activity>(
      'activities',
          (data, documentId) => Activity.fromMap(data, documentId)
  );
});

// Provider for FirestoreService handling Category
final firestoreCategoryServiceProvider = Provider<FirestoreService<category_model.Category>>((ref) {
  return FirestoreService<category_model.Category>(
      'categories',
          (data, documentId) => category_model.Category.fromMap(data, documentId)
  );
});