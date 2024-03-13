import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart'; // Import your home page widget
import 'sign_in_page.dart'; // Import your sign-in page widget

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the user is signed in
        if (snapshot.hasData) {
          return const HomePage(); // User is signed in, navigate to home page
        } else {
          return SignInPage(); // No user is signed in, show sign-in page
        }
      },
    );
  }
}
