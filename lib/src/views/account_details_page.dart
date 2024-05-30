import 'package:budgeting_saving_app/src/views/activities_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budgeting_saving_app/src/models/account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_provider.dart';
import '../utils/constants.dart';
import 'main_screen.dart';

class AccountDetailsPage extends ConsumerWidget {
  final Account? account;
  final bool isNew;

  const AccountDetailsPage({
    super.key,
    this.account,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = TextEditingController(
        text: account?.name ?? '');
    final TextEditingController balanceController = TextEditingController(
        text: account?.balance.toString() ?? '');
    String selectedCurrency = account?.currency ?? 'EUR';
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    void saveAccount() async {
      if (!formKey.currentState!.validate()) return;
      final name = nameController.text.trim();
      final balance = double.tryParse(balanceController.text) ?? 0.0;
      final newAccount = Account(
        id: isNew ? DateTime
            .now()
            .millisecondsSinceEpoch
            .toString() : account!.id,
        // Ensure ID is non-empty
        name: name,
        currency: selectedCurrency,
        balance: balance,
        creatorId: FirebaseAuth.instance.currentUser!.uid,
        userIds: [], // handle user IDs as needed
      );

      try {
        if (isNew) {
          await ref.read(accountNotifierProvider.notifier).addAccount(
              newAccount);
        } else {
          await ref.read(accountNotifierProvider.notifier).updateAccount(
              newAccount);
        }
        Navigator.pop(context, 'Account saved successfully');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save account: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isNew ? 'New Account' : 'Edit Account')),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (value) =>
                value!.isEmpty
                    ? 'Please enter an account name'
                    : null,
              ),
              TextFormField(
                controller: balanceController,
                decoration: const InputDecoration(labelText: 'Initial Balance'),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (value) =>
                value!.isEmpty
                    ? 'Please enter an amount'
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: const InputDecoration(labelText: 'Currency'),
                onChanged: (String? newValue) {
                  selectedCurrency = newValue ?? 'EUR';
                },
                items: currencies.map((currency) => DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                )).toList(),
              ),
              ElevatedButton(
                onPressed: saveAccount,
                child: Text(isNew ? 'Create' : 'Update'),
              ),
              if (!isNew) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    (context.findAncestorStateOfType<MainScreenState>())?.selectAccountAndNavigate(account!.id);
                  },
                  child: const Text('Manage Activities'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}