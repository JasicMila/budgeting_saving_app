import 'package:budgeting_saving_app/src/views/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'sign_in_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the user is signed in
        if (snapshot.hasData) {
          return const MainScreen(); // User is signed in, navigate to home page
        } else {
          return const SignInPage(); // No user is signed in, show sign-in page
        }
      },
    );
  }
}
