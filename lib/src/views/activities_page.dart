import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import 'package:budgeting_saving_app/src/providers/providers.dart';
import '../utils/constants.dart';
import 'activity_details_page.dart';
import 'package:intl/intl.dart';
import 'widgets/gradient_background_scaffold.dart';

class ActivitiesPage extends ConsumerStatefulWidget {
  const ActivitiesPage({super.key});

  @override
  ActivitiesPageState createState() => ActivitiesPageState();
}

class ActivitiesPageState extends ConsumerState<ActivitiesPage> {
  String? selectedAccountId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityNotifierProvider.notifier).fetchActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(activityNotifierProvider);
    final accounts = ref.watch(accountNotifierProvider);

    final filteredActivities = selectedAccountId == null
        ? activities
        : activities
            .where((activity) => activity.accountId == selectedAccountId)
            .toList();

    return GradientBackgroundScaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ActivityDetailsPage(
                      isNew: true, accountId: selectedAccountId ?? '')),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            onPressed: () async {
              await ref.read(activityNotifierProvider.notifier).convertActivityAmounts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity amounts converted')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedAccountId,
              hint: Text('Select Account', style: Theme.of(context).textTheme.titleMedium),
              onChanged: (String? newValue) {
                setState(() {
                  selectedAccountId = newValue;
                  ref
                      .read(activityNotifierProvider.notifier)
                      .fetchActivities(newValue);
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Accounts', style: Theme.of(context).textTheme.bodyLarge),
                ),
                ...accounts.map((account) {
                  return DropdownMenuItem<String>(
                    value: account.id,
                    child: Text(account.name, style: Theme.of(context).textTheme.bodyLarge),
                  );
                }).toList(),
              ],
            ),
          ),
          Expanded(
            child: filteredActivities.isEmpty
                ? Center(child: Text('No activities found', style: Theme.of(context).textTheme.bodyLarge))
                : ListView.builder(
              itemCount: filteredActivities.length,
              itemBuilder: (context, index) {
                final Activity activity = filteredActivities[index];
                final validAccount = accounts
                    .any((account) => account.id == activity.accountId);

                if (!validAccount) {
                  return ListTile(
                    title: Text('Invalid activity (account not found)', style: Theme.of(context).textTheme.bodyLarge),
                  );
                }

                final type = activity.type == ActivityType.income
                    ? 'Income'
                    : 'Expense';
                final formattedDate =
                DateFormat('yyyy-MM-dd').format(activity.date);
                final formattedTime =
                DateFormat('HH:mm').format(activity.date);

                return ListTile(
                  title: Text(
                      '${activity.category} ($type) - ${activity.amount} ${activity.currency}',
                      style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text('$formattedDate at $formattedTime', style: Theme.of(context).textTheme.bodyMedium),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ActivityDetailsPage(
                            activity: activity,
                            isNew: false,
                            accountId: activity.accountId)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.grey[500], // Light grey color
                    onPressed: () {
                      ref
                          .read(activityNotifierProvider.notifier)
                          .removeActivity(activity.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Activity deleted')));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}