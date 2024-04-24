import 'package:budgeting_saving_app/src/views/screens/activities_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budgeting_saving_app/src/models/account.dart';
import 'package:provider/provider.dart';
import '../../services/account_service.dart';


class AccountDetailsPage extends StatefulWidget {
  final Account? account;
  final bool isNew;

  const AccountDetailsPage({
    super.key,
    this.account,
    required this.isNew,
  });

  @override
  AccountDetailsPageState createState() => AccountDetailsPageState();
}

class AccountDetailsPageState extends State<AccountDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  String? _selectedCurrency = 'USD'; // Default or existing account currency
  late AccountService _accountService; // Declare a variable for AccountService
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    _accountService = Provider.of<AccountService>(context, listen: false);  // Get AccountService from Provider
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _amountController =
        TextEditingController(text: widget.account?.amount.toString() ?? '');
    _selectedCurrency = widget.account?.currency ?? 'USD';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    try {
      if (!_formKey.currentState!.validate()) return;
      final name = _nameController.text.trim();
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final account = Account(
        id: widget.account?.id ?? '', // Correct null-aware check
        name: name,
        currency: _selectedCurrency,
        amount: amount,
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      if (widget.isNew) {
        await _accountService.addAccount(account);
      } else {
        await _accountService.updateAccount(account);
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account saved successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save account: $e')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(widget.isNew ? 'New Account' : 'Edit Account')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter an account name' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Initial Amount'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                value!.isEmpty ? 'Please enter an amount' : null,
              ),
              ElevatedButton(
                onPressed: _saveAccount,
                child: Text(widget.isNew ? 'Create' : 'Update'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to ActivitiesPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActivitiesPage(),
                    ),
                  );
                },
                child: const Text('Manage Activities'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}