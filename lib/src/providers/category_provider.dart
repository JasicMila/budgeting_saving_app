import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../notifiers/category_notifier.dart';
import '../services/firestore_service.dart';
import 'firestore_service_provider.dart';

// Provider for managing categories with a specific account ID
final categoryNotifierProvider = StateNotifierProvider.family<CategoryNotifier, List<Category>, String>((ref, accountId) {
  // Fetch the Firestore service specifically for categories
  FirestoreService<Category> service = ref.read(firestoreCategoryServiceProvider);
  // Return a new instance of CategoryNotifier with the specific account ID
  return CategoryNotifier(ref, accountId);
});

