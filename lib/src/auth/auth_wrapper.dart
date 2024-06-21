import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/main_screen.dart';
import 'sign_in_page.dart';
import '../providers/providers.dart';
import '../views/widgets/gradient_background_scaffold.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This line watches the authStateProvider created in the AuthService
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (User? user) => user != null
          ? const MainScreen()
          : GradientBackgroundScaffold(
              appBar: AppBar(
                title: const Text('Sign In'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: const SignInPage(),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
