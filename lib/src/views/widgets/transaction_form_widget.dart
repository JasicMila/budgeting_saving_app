import 'package:flutter/material.dart';
import 'package:budgeting_saving_app/src/models/transaction.dart' as model;
import 'package:budgeting_saving_app/src/models/account.dart';
import 'package:budgeting_saving_app/src/services/account_service.dart';
import 'package:intl/intl.dart';

// Define a callback type for form submission
typedef TransactionFormSubmitCallback = Function(model.Transaction transaction);

class TransactionForm extends StatefulWidget {
  final model.Transaction? initialTransaction;
  final TransactionFormSubmitCallback onSubmit;

  const TransactionForm({
    super.key,
    this.initialTransaction,
    required this.onSubmit,
  });

  @override
  TransactionFormState createState() => TransactionFormState();
}

class TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _category;
  late double _amount;
  late DateTime _date;
  String? selectedAccountId;

  @override
  void initState() {
    super.initState();
    _type = widget.initialTransaction?.type ?? 'expense';
    _category = widget.initialTransaction?.category ?? '';
    _amount = widget.initialTransaction?.amount ?? 0.0;
    _date = widget.initialTransaction?.date ?? DateTime.now();
    selectedAccountId = widget.initialTransaction?.accountId;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            onSaved: (value) => _category = value ?? '',
            validator: (value) => value!.isEmpty ? 'Please enter a category' : null,
          ),
          TextFormField(
            initialValue: _amount.toString(),
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSaved: (value) => _amount = double.tryParse(value!) ?? 0.0,
            validator: (value) {
              if (value == null || double.tryParse(value) == null) return 'Please enter a valid amount';
              return null;
            },
          ),
          FutureBuilder<List<Account>>(
            future: AccountService().fetchAccounts(), // Adjust based on your implementation
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              List<Account> accounts = snapshot.data!;
              return DropdownButtonFormField<String>(
                value: selectedAccountId,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAccountId = newValue;
                  });
                },
                items: accounts.map<DropdownMenuItem<String>>((Account account) {
                  return DropdownMenuItem<String>(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Account',
                ),
              );
            },
          ),
          // Add fields for type and date as needed
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Modify this part to include the accountId in the transaction
      widget.onSubmit(
        model.Transaction(
          id: widget.initialTransaction?.id ?? '',
          accountId: selectedAccountId ?? '', // Use the selected account ID
          type: _type,
          category: _category,
          amount: _amount,
          date: _date,
        ),
      );
    }
  }
}
