import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budgeting_saving_app/src/models/account.dart';

class AccountDetailsPage extends StatefulWidget {
  final Account? account;
  final bool isNew;

  const AccountDetailsPage({super.key, this.account, required this.isNew});

  @override
  AccountDetailsPageState createState() => AccountDetailsPageState();
}

class AccountDetailsPageState extends State<AccountDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  String? _selectedCurrency = 'USD'; // Default or existing account currency

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _amountController = TextEditingController(text: widget.account?.amount.toString() ?? '');
    _selectedCurrency = widget.account?.currency ?? 'USD';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final Map<String, dynamic> accountData = {
      'name': name,
      'currency': _selectedCurrency,
      'amount': amount,
      'userId': FirebaseAuth.instance.currentUser?.uid, // Ensure you have the user ID
    };
    // Add new account or update existing one
    if (widget.isNew) {
      await FirebaseFirestore.instance.collection('accounts').add(accountData);
    } else {
      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(widget.account?.id)
          .update(accountData);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isNew ? 'New Account' : 'Edit Account')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (value) => value!.isEmpty ? 'Please enter an account name' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Initial Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value!.isEmpty ? 'Please enter an amount' : null,
              ),
              // Currency selector and any additional fields go here
              ElevatedButton(
                onPressed: _saveAccount,
                child: Text(widget.isNew ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
