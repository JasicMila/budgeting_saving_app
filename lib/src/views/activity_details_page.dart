
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../providers/activity_provider.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import 'package:budgeting_saving_app/src/utils/constants.dart';
import 'package:intl/intl.dart';

class ActivityDetailsPage extends ConsumerStatefulWidget {
  final Activity? activity;
  final bool isNew;
  final String accountId;

  const ActivityDetailsPage({
    super.key,
    this.activity,
    required this.isNew,
    required this.accountId,
    });

  @override
  ActivityDetailsPageState createState() => ActivityDetailsPageState();
}

class ActivityDetailsPageState extends ConsumerState<ActivityDetailsPage> {
  late TextEditingController amountController;
  late TextEditingController categoryController;
  late DateTime selectedDate;
  late ActivityType selectedType;
  late String selectedCurrency;
  late String selectedAccountId;
  String? selectedCategory;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.activity?.amount.toString());
    categoryController = TextEditingController(text: widget.activity?.category);
    selectedDate = widget.activity?.date ?? DateTime.now();
    selectedType = widget.activity != null ? ActivityType.values.firstWhere(
            (e) => e.toString().split('.').last == widget.activity!.type,
        orElse: () => ActivityType.expense
    ) : ActivityType.expense; // Default to 'expense'
    selectedCurrency = widget.activity?.currency ?? 'EUR';  // Default to 'EUR'
    selectedAccountId = widget.activity?.accountId ?? widget.accountId;
    selectedCategory = widget.activity?.category;
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get the current logged-in user
    final creatorId = user?.uid ?? 'auto'; // Use user ID or 'auto' as fallback
    final accounts = ref.watch(accountNotifierProvider);
    final categories = ref.watch(categoryNotifierProvider(selectedAccountId));

    // Filter categories based on selected type
    final filteredCategories = categories.where((category) =>
    category.type == selectedType.toString().split('.').last).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New Activity' : 'Edit Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey, // Connect the GlobalKey
          child: ListView(
            children: [

              DropdownButtonFormField<String>(
                value: selectedAccountId.isNotEmpty ? selectedAccountId : null,
                decoration: const InputDecoration(labelText: 'Account'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAccountId = newValue!;
                  });
                },
                items: accounts.map<DropdownMenuItem<String>>((Account account) {
                  return DropdownMenuItem<String>(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select an account' : null,
              ),

              DropdownButtonFormField<ActivityType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                onChanged: (ActivityType? newValue) {
                  setState(() {
                    selectedType = newValue!;
                    selectedCategory = null; // Reset category when type changes
                  });
                },
                items: ActivityType.values.map((ActivityType type) {
                  return DropdownMenuItem<ActivityType>(
                  value: type,
                  child: Text(type.toString().split('.').last),
                  );
                }).toList(),
              ),

              DropdownButtonFormField<String>(
                value: categories.isNotEmpty && selectedCategory != null
                    ? filteredCategories.firstWhere(
                        (category) => category.name == selectedCategory,
                    orElse: () => filteredCategories.first)
                    .name
                    : null,
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (String? newValue) {
                  setState(() {
                    categoryController.text = newValue!;
                    selectedCategory = newValue;
                  });
                },
                items: filteredCategories.map<DropdownMenuItem<String>>((Category category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),

              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a valid amount' : null,
              ),

              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: const InputDecoration(labelText: 'Currency'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCurrency = newValue ?? currencies.first;
                  });
                },
                items: currencies.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
              ),

              ListTile(
                title: Text('Date: ${DateFormat.yMd().format(selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != selectedDate && mounted) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),

              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Activity updatedActivity = Activity(
                      id: widget.activity?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      accountId: selectedAccountId,
                      date: selectedDate,
                      type: selectedType,
                      category: categoryController.text,
                      amount: double.parse(amountController.text),
                      currency: selectedCurrency,
                      creatorId: creatorId,
                    );
                    if (widget.isNew) {
                      await ref.read(activityNotifierProvider.notifier).addActivity(updatedActivity);
                    } else {
                      await ref.read(activityNotifierProvider.notifier).updateActivity(updatedActivity.id, updatedActivity);
                    }
                    // Check if the widget is still in the tree after the async operation
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity saved successfully')));
                    }
                  }
                },
                child: Text(widget.isNew ? 'Create' : 'Update'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    categoryController.dispose();
    super.dispose();
  }
}