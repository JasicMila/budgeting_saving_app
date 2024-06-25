import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgeting_saving_app/src/providers/providers.dart';
import '../views/widgets/elevated_button.dart';
import '../views/widgets/gradient_background_scaffold.dart';
import '../views/widgets/text_form_field.dart';
import '../models/account.dart';


class RegistrationPage extends ConsumerWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final displayNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return GradientBackgroundScaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextFormField(
                controller: displayNameController,
                labelText: 'Username',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                controller: emailController,
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                controller: passwordController,
                labelText: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              CustomElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final authService = ref.read(authServiceProvider);
                      await authService.createUser(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );

                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final displayName = displayNameController.text.trim();
                        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                          'displayName': displayName,
                          'email': user.email,
                        });

                        final defaultAccount = Account(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: 'Main',
                          currency: 'EUR',
                          balance: 0.0,
                          creatorId: user.uid,
                          userIds: [user.uid],
                        );

                        await ref.read(accountNotifierProvider.notifier).addAccount(defaultAccount);
                      }

                      Navigator.pop(context); // Return to sign in page after successful registration
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration successful')),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to register: $error')),
                      );
                    }
                  }
                },
                text: 'Register',
              ),
            ],
          ),
        ),
      ),
    );
  }
}