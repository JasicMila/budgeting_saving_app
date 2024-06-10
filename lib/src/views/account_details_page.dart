
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budgeting_saving_app/src/models/account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgeting_saving_app/src/providers/providers.dart';
import '../utils/constants.dart';
import 'activity_details_page.dart';
import 'widgets/text_form_field.dart';
import 'widgets/dropdown_form_field.dart';
import 'widgets/elevated_button.dart';

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
              CustomTextFormField(
                controller: nameController,
                labelText: 'Account Name',
                validator: (value) =>
                value!.isEmpty
                    ? 'Please enter an account name'
                    : null,
              ),
              CustomTextFormField(
                controller: balanceController,
                labelText: 'Initial Balance',
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (value) =>
                value!.isEmpty
                    ? 'Please enter an amount'
                    : null,
              ),
              CustomDropdownFormField<String>(
                value: selectedCurrency,
                labelText: 'Currency',
                onChanged: (String? newValue) {
                  selectedCurrency = newValue ?? 'EUR';
                },
                items: currencies.map((currency) => DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                )).toList(),
              ),
              CustomElevatedButton(
                onPressed: saveAccount,
                text: isNew ? 'Create' : 'Update',
              ),
              if (!isNew) ...[
                CustomElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailsPage(
                          activity: null, // Assuming it's a new activity
                          isNew: true, // Set to true since it's a new activity
                          accountId: account!.id,
                        ),
                      ),
                    );
                  },
                  text: 'Manage Activities',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}