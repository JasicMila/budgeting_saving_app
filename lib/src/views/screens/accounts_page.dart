import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String? userId = FirebaseAuth.instance.currentUser?.uid;

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  AccountsPageState createState() => AccountsPageState();
}

class AccountsPageState extends State<AccountsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController accountNameController = TextEditingController();
  String? _selectedCurrency = 'EUR';
  final List<String> _currencies = ['USD', 'EUR']; // Initial currency options

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      // Ensure you have a user before proceeding
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user signed in')),
        );
        return; // Exit if there is no user
      }
      // Define the account data, including the user's UID
      final Map<String, dynamic> accountData = {
        'name': accountNameController.text.trim(),
        'currency': _selectedCurrency,
        'userId': userId, // Link the account to the user
      };

      try {
        // Save the account data to Firestore
        await FirebaseFirestore.instance
            .collection('accounts')
            .add(accountData);

        if (!mounted) return; // Check if the widget is still mounted

        // UI feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
      } catch (e) {
        if (!mounted)
          return; // Check if the widget is still mounted before trying to show a SnackBar

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create account')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Your Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Associate your Form with the _formKey
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: accountNameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an account name';
                  }
                  return null; // Return null if the input is valid
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  hintText: 'Select your main currency',
                ),
                items:
                    _currencies.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a currency';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createAccount, // Update this line
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    accountNameController.dispose();
    super.dispose();
  }
}
