import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../views/widgets/elevated_button.dart';
import '../views/widgets/text_form_field.dart';
import '../providers/providers.dart';
import 'registration_page.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  }
                  return null;
                },
              ),
              CustomElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    ref.read(authServiceProvider).signIn(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  }
                },
                text: 'Sign In',
              ),

              TextButton(
                onPressed: () {
                  // Navigate to the registration page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrationPage()),
                  );
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}