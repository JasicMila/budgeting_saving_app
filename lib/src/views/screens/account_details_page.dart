import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budgeting_saving_app/src/models/account.dart';
import 'package:budgeting_saving_app/src/models/transaction.dart' as model;
import 'package:budgeting_saving_app/src/views/widgets/transaction_form_widget.dart';
import 'package:intl/intl.dart';

class AccountDetailsPage extends StatefulWidget {
  final Account? account;
  final bool isNew;
  final model.Transaction? initialTransaction;

  const AccountDetailsPage({
    super.key,
    this.account,
    required this.isNew,
    this.initialTransaction, //Initialize in constructor
  });

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
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final Map<String, dynamic> accountData = {
      'name': name,
      'currency': _selectedCurrency,
      'amount': amount,
      'userId': FirebaseAuth.instance.currentUser?.uid,
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

  void _openTransactionForm([model.Transaction? existingTransaction]) {
    // If an existing transaction is passed, we're in edit mode; otherwise, create mode
    showModalBottomSheet(
      context: context,
      builder: (_) => TransactionForm(
        initialTransaction: existingTransaction ?? model.Transaction(
          accountId: widget.account?.id ?? '',
          // Default values for a new transaction
          amount: 0.0,
          category: '',
          type: 'expense',
          date: DateTime.now(),
        ),
        onSubmit: (transaction) async {
          _handleTransactionSubmission(transaction);
        },
      ),
    );
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
              ListTile(
                onTap: () => _openTransactionForm(),
                // Pass the transaction to edit
                title: const Text("Transaction Title"),
                subtitle: const Text("Transaction Details"),
              ),
              // Currency selector and any additional fields go here
              ElevatedButton(
                onPressed: _saveAccount,
                child: Text(widget.isNew ? 'Create' : 'Update'),
              ),
              FloatingActionButton(
                onPressed: () => _openTransactionForm(),
                // Open form for a new transaction
                child: const Icon(Icons.add),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTransactionsList(String accountId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('accountId', isEqualTo: accountId)
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final transactions = snapshot.data!.docs
            .map((doc) =>
            model.Transaction.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return ListTile(
              title: Text(
                  '${transaction.type.toUpperCase()}: ${transaction.category}'),
              subtitle: Text(
                  '${transaction.amount} - ${DateFormat.yMd().format(
                      transaction.date)}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    _openTransactionForm(),
              ),
            );
          },
        );
      },
    );
  }

  void _handleTransactionSubmission(model.Transaction transaction) async {
    final transactionCollection =
    FirebaseFirestore.instance.collection('transactions');
    try {
      if (transaction.id.isNotEmpty) {
        // Update existing transaction
        await transactionCollection
            .doc(transaction.id)
            .update(transaction.toMap());
      } else {
        // Add new transaction
        await transactionCollection.add(transaction.toMap());
      }

      // Close the form and show success message
      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction saved successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving transaction')));
    }
  }
}
