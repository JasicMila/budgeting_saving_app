import 'package:flutter/material.dart';
import 'package:budgeting_saving_app/src/models/transaction.dart' as model;
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

  @override
  void initState() {
    super.initState();
    _type = widget.initialTransaction?.type ?? 'expense';
    _category = widget.initialTransaction?.category ?? '';
    _amount = widget.initialTransaction?.amount ?? 0.0;
    _date = widget.initialTransaction?.date ?? DateTime.now();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(
        model.Transaction(
          id: widget.initialTransaction?.id ?? '',
          accountId: widget.initialTransaction?.accountId ?? '',
          type: _type,
          category: _category,
          amount: _amount,
          date: _date,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
          // Add fields for type and date as needed
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
