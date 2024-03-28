import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'account_details_page.dart';
import 'package:budgeting_saving_app/src/models/account.dart';
import '../../services/account_service.dart';


class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  AccountsPageState createState() => AccountsPageState();
}

class AccountsPageState extends State<AccountsPage> {
  final AccountService _accountService = AccountService(); // Instantiate the AccountService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountDetailsPage(isNew: true)),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Account>>(
        future: _accountService.fetchAccounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator(); // Show loading indicator while waiting for data
          }
          if (snapshot.hasError) {
            // Displaying a SnackBar in case of an error
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to fetch accounts. Please try again.')),
              );
            });
            return const Text('Failed to load');
          }
          if (!snapshot.hasData) {
            return const Text('No accounts found'); // Show a message if no accounts are found
          }
          final List<Account> accounts = snapshot.data!;

          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                title: Text(account.name),
                subtitle: Text('${account.currency} ${account.amount.toStringAsFixed(2)}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountDetailsPage(account: account, isNew: false)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountDetailsPage(account: account, isNew: false)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // Start async operation
                        await FirebaseFirestore.instance.collection('accounts').doc(account.id).delete();

                        // Check if the widget is still mounted before using context
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted')));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


