import 'package:flutter/material.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  AccountsPageState createState() => AccountsPageState();
}

class AccountsPageState extends State<AccountsPage> {
  final TextEditingController accountNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Your Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: accountNameController,
              decoration: const InputDecoration(labelText: 'Account Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Here, you would add the logic to create the account
                // For now, we'll just pop back to the previous screen
                Navigator.pop(context);
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    accountNameController.dispose();
    super.dispose();
  }
}
