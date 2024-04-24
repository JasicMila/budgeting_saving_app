
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'account_details_page.dart';
import '../../services/account_service.dart';


class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var accountService = Provider.of<AccountService>(context);
    var accounts = accountService.accounts;  // Directly use the accounts from the provider

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

    body: ListView.builder(
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
                    onPressed: () {
                      accountService.deleteAccount(account.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted')));
                    },
                  ),
                ],
              ),
            );
          },
      ),
    );
  }
}