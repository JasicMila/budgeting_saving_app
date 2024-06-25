// providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgeting_saving_app/src/auth/auth_service.dart';
import 'package:budgeting_saving_app/src/notifiers/account_notifier.dart';
import 'package:budgeting_saving_app/src/notifiers/activity_notifier.dart';
import 'package:budgeting_saving_app/src/notifiers/category_notifier.dart';
import 'package:budgeting_saving_app/src/models/account.dart';
import 'package:budgeting_saving_app/src/models/activity.dart';
import 'package:budgeting_saving_app/src/models/category.dart';
import 'package:budgeting_saving_app/src/services/firestore_service.dart';
import 'package:logger/logger.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Firestore Service Providers
final firestoreAccountServiceProvider =
    Provider<FirestoreService<Account>>((ref) {
  return FirestoreService<Account>(
    'accounts',
    (data, documentId) => Account.fromMap(data, documentId),
  );
});

final firestoreActivityServiceProvider =
    Provider<FirestoreService<Activity>>((ref) {
  return FirestoreService<Activity>(
    'activities',
    (data, documentId) => Activity.fromMap(data, documentId),
  );
});

final firestoreCategoryServiceProvider =
    Provider<FirestoreService<Category>>((ref) {
  return FirestoreService<Category>(
    'categories',
    (data, documentId) => Category.fromMap(data, documentId),
  );
});

// Notifier Providers
final accountNotifierProvider =
    StateNotifierProvider<AccountNotifier, List<Account>>((ref) {
  return AccountNotifier(ref);
});

final activityNotifierProvider =
    StateNotifierProvider<ActivityNotifier, List<Activity>>((ref) {
  return ActivityNotifier(ref);
});

final categoryNotifierProvider =
    StateNotifierProvider.family<CategoryNotifier, List<Category>, String>(
        (ref, accountId) {
  return CategoryNotifier(ref, accountId);
});

// User Provider
final userProvider = StreamProvider<UserData?>((ref) {
  return ref.watch(authStateChangesProvider.stream).asyncMap((user) async {
    if (user != null) {
      try {
        final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        Logger().i("Fetched user data: ${userData.data()}");
        return UserData(
          uid: user.uid,
          email: user.email!,
          displayName: userData.data()?['displayName'] ?? 'User',
        );
      } catch (e) {
        Logger().e("Failed to fetch user data: $e");
        return null;
      }
    }
    return null;
  });
});

class UserData {
  final String uid;
  final String email;
  final String displayName;

  UserData({required this.uid, required this.email, required this.displayName});
}