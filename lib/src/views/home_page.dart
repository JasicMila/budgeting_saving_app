import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgeting_saving_app/src/auth/auth_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'widgets/gradient_background_scaffold.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider);

    return GradientBackgroundScaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Refresh user provider to clear old user data
              ref.invalidate(userProvider);
              // Navigate to AuthWrapper after logging out
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthWrapper()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: userAsyncValue.when(
          data: (user) => Text('Welcome, ${user?.displayName ?? "User"}!'),
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text('Error loading user data'),
        ),
      ),
    );
  }
}