import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:budgeting_saving_app/src/models/transaction.dart' as model;
import 'package:intl/intl.dart';
import '../../services/account_service.dart';
import '../widgets/transaction_form_widget.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  TransactionsPageState createState() => TransactionsPageState();
}

class TransactionsPageState extends State<TransactionsPage> {
  Map<String, String> accountNames = {};

  @override
  void initState() {
    super.initState();
    fetchAccountNames();
  }

  void fetchAccountNames() async {
    accountNames = await AccountService().fetchAccountNames();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Use Firestore to listen to changes and display the list of transactions
        stream:
            FirebaseFirestore.instance.collection('transactions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          // Build your list of transactions
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var transaction = model.Transaction.fromMap(
                  doc.data() as Map<String, dynamic>, doc.id);

              return ListTile(
                title: Text("${transaction.category} - ${transaction.amount}"),
                subtitle: Text(
                    "${DateFormat.yMd().format(transaction.date)} | Account: ${accountNames[transaction.accountId] ?? 'Unknown'}"),
                onTap: () => navigateToTransactionForm(context, transaction),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToTransactionForm(context),
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  void navigateToTransactionForm(BuildContext context,
      [model.Transaction? transactionToEdit]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Transaction Form'),
          ),
          body: TransactionForm(
            initialTransaction: transactionToEdit,
            onSubmit: (model.Transaction transaction) async {
              // Execute async operation to save the transaction
              try {
                if (transaction.id.isEmpty) {
                  // Add a new transaction if id is empty
                  await FirebaseFirestore.instance
                      .collection('transactions')
                      .add(transaction.toMap());
                } else {
                  // Update the existing transaction
                  await FirebaseFirestore.instance
                      .collection('transactions')
                      .doc(transaction.id)
                      .update(transaction.toMap());
                }
                // Use context after checking for mounted to avoid using it across async gap
                if (!mounted) return;
                // Navigate back if the widget is still mounted
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Transaction saved successfully.')),
                );
              } catch (e) {
                print(e);
                if (!mounted) return;
                // Show error feedback if the widget is still mounted
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Failed to save transaction. Please try again.')),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
