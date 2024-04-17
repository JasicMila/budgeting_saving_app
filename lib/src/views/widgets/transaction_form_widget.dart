
import 'package:flutter/material.dart';
import 'package:budgeting_saving_app/src/models/transaction.dart' as model;
import 'package:budgeting_saving_app/src/models/account.dart';
import 'package:budgeting_saving_app/src/models/category.dart' as app;
import 'package:budgeting_saving_app/src/services/account_service.dart';
import 'package:budgeting_saving_app/src/services/category_service.dart' as app;


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
  late String _category;
  late double _amount;
  late DateTime _date;
  String? selectedAccountId;
  String _selectedType = 'expense'; // Default value

  @override
  void initState() {
    super.initState();
    _category = widget.initialTransaction?.category ?? '';
    _amount = widget.initialTransaction?.amount ?? 0.0;
    _date = widget.initialTransaction?.date ?? DateTime.now();
    selectedAccountId = widget.initialTransaction?.accountId;
    _selectedType = widget.initialTransaction?.type ?? 'expense';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          DropdownButtonFormField<String>(
            value: _selectedType,
            onChanged: (String? newValue) {
              setState(() {
                _selectedType = newValue!;
              });
            },
            items: <String>['income', 'expense']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: 'Transaction Type',
            ),
          ),

          TextFormField(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            onSaved: (value) => _category = value ?? '',
            validator: (value) =>
                value!.isEmpty ? 'Please enter a category' : null,
          ),
          TextFormField(
            initialValue: _amount.toString(),
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSaved: (value) => _amount = double.tryParse(value!) ?? 0.0,
            validator: (value) {
              if (value == null || double.tryParse(value) == null)
                return 'Please enter a valid amount';
              return null;
            },
          ),
          FutureBuilder<List<Account>>(
            future: AccountService().fetchAccounts(),
            // Adjust based on your implementation
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
                items:
                    accounts.map<DropdownMenuItem<String>>((Account account) {
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
          FutureBuilder<List<app.Category>>(
            future: app.CategoryService().fetchCategories(type: _selectedType),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              List<String> categoryNames = snapshot.data!
                  .map((category) => category.name)
                  .toSet() // Remove duplicates
                  .toList();

              if (!categoryNames.contains('Add New...')) {
                categoryNames.add('Add New...');
              }

              if (_category == null || !categoryNames.contains(_category)) {
                _category = categoryNames.first;
              }

              print("Category Names: $categoryNames");
              print("Current Value of _category: $_category");

              return DropdownButtonFormField<String>(
                value: _category,
                onChanged: (String? newValue) {
                  if (newValue == 'Add New...') {
                    _promptAddNewCategory(context);
                  } else {
                    setState(() {
                      _category = newValue!;
                    });
                  }
                },
                items:
                    categoryNames.map<DropdownMenuItem<String>>((String name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Category',
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

  void _promptAddNewCategory(BuildContext context) {
    TextEditingController newCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: newCategoryController,
          decoration: const InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final String newCategoryName = newCategoryController.text.trim();
              if (newCategoryName.isNotEmpty) {
                // Create a new Category object
                final newCategory = app.Category(
                  name: newCategoryName,
                  type:
                      _selectedType, // Make sure _selectedType is accessible here
                );
                // Save new category to Firestore using CategoryService
                await app.CategoryService().addCategory(newCategory);

                setState(() {
                  _category =
                      newCategoryName; // Set the newly added category as selected
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(
        model.Transaction(
          id: widget.initialTransaction?.id ?? '',
          accountId: selectedAccountId ?? '',
          // Use the selected account ID
          type: _selectedType,
          category: _category,
          amount: _amount,
          date: _date,
        ),
      );
    }
  }
}
