import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgeting_saving_app/src/providers/providers.dart';
import 'account_details_page.dart';
import 'widgets/gradient_background_scaffold.dart';

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});

  @override
  AccountsPageState createState() => AccountsPageState();
}

class AccountsPageState extends ConsumerState<AccountsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountNotifierProvider.notifier).fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountNotifierProvider);


    return GradientBackgroundScaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AccountDetailsPage(isNew: true)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            onPressed: () async {
              await ref.read(accountNotifierProvider.notifier).convertAccountBalances();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account balances converted')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return ListTile(
            title: Text(account.name, style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text(
                '${account.currency} ${account.balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AccountDetailsPage(account: account, isNew: false)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.grey[500], // Light grey color
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountDetailsPage(
                            account: account, isNew: false)),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.grey[500], // Light grey color
                    onPressed: () async {
                      await ref
                          .read(accountNotifierProvider.notifier)
                          .removeAccount(account.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Account and related activities deleted')));
                      }
                    }),
              ],
            ),
          );
        },
      ),
    );
  }
}
