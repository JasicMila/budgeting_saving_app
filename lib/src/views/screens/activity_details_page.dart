import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/activity_service.dart';
import '../../models/activity.dart';
import '../../services/account_service.dart';
import '../../models/account.dart';
import '../../services/category_service.dart';
import 'package:budgeting_saving_app/src/models/category.dart' as category_model;
import 'package:budgeting_saving_app/src/utils/constants.dart';

class ActivityDetailsPage extends StatefulWidget {
  final Activity? activity;
  final bool isNew;

  const ActivityDetailsPage({super.key, this.activity, required this.isNew});

  @override
  ActivityDetailsPageState createState() => ActivityDetailsPageState();
}

class ActivityDetailsPageState extends State<ActivityDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  late DateTime _selectedDate;
  String _selectedType = 'expense'; // Default to 'expense'
  String? _selectedAccountId;
  String _selectedCurrency = 'EUR';
  List<category_model.Category> _availableCategories = [];
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.activity?.amount.toString() ?? '');
    _categoryController =
        TextEditingController(text: widget.activity?.category ?? '');
    _selectedDate = widget.activity?.date ?? DateTime.now();
    _selectedType = widget.activity?.type ?? 'expense';
    _selectedAccountId = widget.activity?.accountId;
    _selectedCurrency = widget.activity?.currency ?? 'EUR';
    _loadInitialData();
  }

  void _loadInitialData() async {
    final categoryService =
        Provider.of<CategoryService>(context, listen: false);
    final accountService = Provider.of<AccountService>(context, listen: false);
    await categoryService.fetchCategories(type: _selectedType);
    _accounts = accountService.accounts;
    setState(() {
      _availableCategories = categoryService.categories;
      if (_selectedAccountId == null && _accounts.isNotEmpty) {
        _selectedAccountId = _accounts.first.id;
      }
    });
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryService = Provider.of<CategoryService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Activity' : 'Edit Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // Wrap your input fields in a Form widget
          key: _formKey, // Connect the GlobalKey
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              DropdownButton<String>(
                value: _selectedType,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                    _loadInitialData(); // Reload categories when type changes
                  });
                },
                items: <String>['income', 'expense'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
              if (_accounts.isNotEmpty)
                DropdownButton<String>(
                  value: _selectedAccountId,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAccountId = newValue!;
                    });
                  },
                  items: _accounts.map((Account account) {
                    return DropdownMenuItem<String>(
                      value: account.id,
                      child: Text(account.name),
                    );
                  }).toList(),
                ),
              DropdownButton<String>(
                value: _selectedCurrency,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrency = newValue!;
                  });
                },
                items: currencies.map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
              ),
              DropdownButton<String>(
                value: _categoryController.text.isNotEmpty
                    ? _categoryController.text
                    : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _categoryController.text = newValue!;
                  });
                },
                items: _availableCategories.isNotEmpty
                ? _availableCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList() :
                [const DropdownMenuItem(child: Text("No Categories Available"))],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Picked Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  ),
                  TextButton(
                    onPressed: _presentDatePicker,
                    child: const Text(
                      'Choose Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveActivity();
                  }
                },
                child: Text(widget.isNew ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final activityService =
          Provider.of<ActivityService>(context, listen: false);
      final newActivity = Activity(
        id: widget.activity?.id ?? '',
        accountId: _selectedAccountId!,
        userId: FirebaseAuth.instance.currentUser!.uid,
        amount: double.parse(_amountController.text),
        type: _selectedType,
        category: _categoryController.text,
        date: _selectedDate,
        currency: _selectedCurrency,
      );

      if (widget.isNew) {
        activityService.addActivity(newActivity);
      } else {
        activityService.updateActivity(newActivity);
      }
      Navigator.pop(context);
    }

    @override
    void dispose() {
      _amountController.dispose();
      _categoryController.dispose();
      super.dispose();
    }
  }
}
