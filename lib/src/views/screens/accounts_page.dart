import 'package:budgeting_saving_app/src/models/account.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';


class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  AccountsPageState createState() => AccountsPageState();
}

class AccountsPageState extends State<AccountsPage> {
  final TextEditingController accountNameController = TextEditingController();
  String? _selectedCurrency = 'EUR';
  final List<String> _currencies = ['USD', 'EUR'];
  final TextEditingController amountController = TextEditingController();

  Future<void> createAccount() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No user signed in')));
      return;
    }

    final account = Account(
      name: accountNameController.text.trim(),
      currency: _selectedCurrency!,
      amount: double.tryParse(amountController.text) ?? 0.0, // Ensure a default value is set
      userId: userId,
    );

    try {
      await FirebaseFirestore.instance.collection('accounts').add(account.toMap());
      if (!mounted) return; // Check if the widget is still in the widget tree
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully!')));
    } catch (e) {
      if (!mounted) return; // Check again because we're after an async gap
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create account')));
    }

  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Your Accounts")),
        body: const Center(child: Text("Please sign in to view accounts")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Accounts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAccountDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('accounts').where('userId', isEqualTo: currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          final accounts = snapshot.data!.docs.map((doc) => Account.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              final formattedAmount = NumberFormat.currency(locale: 'en_US', symbol: account.currency == 'USD' ? '\$' : '€').format(account.amount);
              return ListTile(
                title: Text(account.name),
                subtitle: Text(formattedAmount),
              );
            },
          );
        },
      )

    );
  }

  void _showCreateAccountDialog() {
    // Define a local key for the form in the dialog
    final GlobalKey<FormState> dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Account'),
          content: SingleChildScrollView(
            child: Form(
              // Wrap with Form widget
              key: dialogFormKey, // Use the local form key
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: accountNameController,
                    decoration:
                        const InputDecoration(labelText: 'Account Name'),
                    validator: (value) {
                      // Add a validator for form validation
                      if (value == null || value.isEmpty) {
                        return 'Please enter an account name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: amountController,
                    decoration:
                        const InputDecoration(labelText: 'Initial Amount'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an initial amount';
                      }
                      // Validate for a valid number format
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null; // Input is valid
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: _currencies.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCurrency = newValue;
                      });
                    },
                    validator: (value) {
                      // Add a validator for the dropdown
                      if (value == null || value.isEmpty) {
                        return 'Please select a currency';
                      }
                      return null;
                    },
                  ),
                  // Include any other form fields here
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (dialogFormKey.currentState!.validate()) {
                  // Check if form is valid
                  createAccount();
                  dialogFormKey.currentState?.reset();
                  // Close the dialog only if form is valid
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    accountNameController.dispose();
    super.dispose();
  }
}
