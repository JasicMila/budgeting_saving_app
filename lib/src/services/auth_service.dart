import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    if(email.isEmpty || password.isEmpty) {
      throw CustomAuthException("Email and password cannot be empty.");
    }
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw CustomAuthException("Failed to sign in: ${e.message}");
      } else {
        throw CustomAuthException("An unexpected error occurred");
      }
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> createUser(String email, String password) async {
    if(email.isEmpty || password.isEmpty) {
      throw CustomAuthException("Email and password cannot be empty.");
    }
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw CustomAuthException("Failed to create user: ${e.message}");
      } else {
        throw CustomAuthException("An unexpected error occurred");
      }
    }
  }
}

class CustomAuthException implements Exception {
  final String message;
  CustomAuthException(this.message);

  @override
  String toString() => "CustomAuthException: $message";
}

