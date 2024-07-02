
import 'package:budgeting_saving_app/src/views/widgets/gradient_background_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budgeting_saving_app/src/models/account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgeting_saving_app/src/providers/providers.dart';
import '../utils/constants.dart';
import '../utils/currencies.dart';
import 'activity_details_page.dart';
import 'widgets/text_form_field.dart';
import 'widgets/dropdown_form_field.dart';
import 'widgets/elevated_button.dart';

class AccountDetailsPage extends ConsumerStatefulWidget{
  final Account? account;
  final bool isNew;

  const AccountDetailsPage({
    super.key,
    this.account,
    required this.isNew,
  });

  @override
  ConsumerState<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends ConsumerState<AccountDetailsPage> {
  late TextEditingController nameController;
  late TextEditingController balanceController;
  late String selectedCurrency;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.account?.name ?? '');
    balanceController = TextEditingController(text: widget.account?.balance.toString() ?? '');
    selectedCurrency = widget.account?.currency ?? availableCurrencies.keys.first;
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GradientBackgroundScaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Account' : 'Edit Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an amount';
                  } else if (double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              CustomDropdownFormField<String>(
                value: selectedCurrency,
                labelText: 'Currency',
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCurrency = newValue ?? availableCurrencies.keys.first;
                  });
                },
                items: availableCurrencies.entries.map<DropdownMenuItem<String>>((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text('${entry.key} - ${entry.value}'),
                  );
                }).toList(),
              ),
              CustomElevatedButton(
                onPressed: saveAccount,
                text: widget.isNew ? 'Create' : 'Update',
              ),
              if (!widget.isNew) ...[
                CustomElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailsPage(
                          activity: null, // Assuming it's a new activity
                          isNew: true, // Set to true since it's a new activity
                          accountId: widget.account!.id,
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

  void saveAccount() async {
    if (!formKey.currentState!.validate()) return;
    final name = nameController.text.trim();
    final balance = double.tryParse(balanceController.text) ?? 0.0;
    final newAccount = Account(
      id: widget.isNew ? DateTime.now().millisecondsSinceEpoch.toString() : widget.account!.id,
      name: name,
      currency: selectedCurrency,
      balance: balance,
      creatorId: FirebaseAuth.instance.currentUser!.uid,
      userIds: [], // handle user IDs as needed
    );

    try {
      if (widget.isNew) {
        await ref.read(accountNotifierProvider.notifier).addAccount(newAccount);
      } else {
        if (widget.account!.name != name) {
          bool isUnique = await ref.read(firestoreAccountServiceProvider).isAccountNameUnique(name, widget.account!.id);
          print('Is account name unique? $isUnique');
          if (!isUnique) {
            throw Exception('Account name must be unique');
          }
        }
        await ref.read(accountNotifierProvider.notifier).updateAccount(newAccount);
      }
      Navigator.pop(context, 'Account saved successfully');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save account: $e')));
    }
  }
}
