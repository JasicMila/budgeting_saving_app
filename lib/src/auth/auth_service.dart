import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signIn(String email, String password) async {
    if(email.isEmpty || password.isEmpty) {
      throw CustomAuthException("Email and password cannot be empty.");
    }
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _logger.e("Failed to sign in", error: e);
      if (e is FirebaseAuthException) {
        throw CustomAuthException("Failed to sign in: ${e.message}");
      } else {
        throw CustomAuthException("An unexpected error occurred");
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      _logger.e("Failed to sign out", error: e);
      throw CustomAuthException("Failed to sign out");
    }
  }

  Future<void> createUser(String email, String password) async {
    if(email.isEmpty || password.isEmpty) {
      throw CustomAuthException("Email and password cannot be empty.");
    }
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _logger.e("Failed to create user", error: e);
      if (e is FirebaseAuthException) {
        throw CustomAuthException("Failed to create user: ${e.message}");
      } else {
        throw CustomAuthException("An unexpected error occurred");
      }
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      throw CustomAuthException("Email cannot be empty.");
    }
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _logger.e("Failed to reset password", error: e);
      if (e is FirebaseAuthException) {
        throw CustomAuthException("Failed to reset password: ${e.message}");
      } else {
        throw CustomAuthException("An unexpected error occurred");
      }
    }
  }

  Future<void> updateEmail(String newEmail) async {
    if (newEmail.isEmpty) {
      throw CustomAuthException("Email cannot be empty.");
    }
    try {
      await _firebaseAuth.currentUser?.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      _logger.e("Failed to update email", error: e);
      if (e is FirebaseAuthException) {
        throw CustomAuthException("Failed to update email: ${e.message}");
      } else {
        throw CustomAuthException("An unexpected error occurred");
      }
    }
  }

  Future<void> updatePassword(String newPassword) async {
    if (newPassword.isEmpty) {
      throw CustomAuthException("Password cannot be empty.");
    }
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      _logger.e("Failed to update password", error: e);
      if (e is FirebaseAuthException) {
        throw CustomAuthException("Failed to update password: ${e.message}");
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

