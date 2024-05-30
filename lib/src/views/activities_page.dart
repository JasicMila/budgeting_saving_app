import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import 'package:budgeting_saving_app/src/providers/account_provider.dart';
import 'package:budgeting_saving_app/src/providers/activity_provider.dart';
import 'activity_details_page.dart';


class ActivitiesPage extends ConsumerStatefulWidget {
  final String accountId;

  const ActivitiesPage({super.key, required this.accountId});

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
        : activities.where((activity) => activity.accountId == selectedAccountId).toList();


    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ActivityDetailsPage(isNew: true, accountId: selectedAccountId ?? '')),
            ),
          ),
        ],
      ),
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: selectedAccountId,
                hint: const Text('Select Account'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAccountId = newValue;
                    ref.read(activityNotifierProvider.notifier).fetchActivities(newValue);
                  });
                },
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Accounts'),
                  ),
                  ...accounts.map((account) {
                    return DropdownMenuItem<String>(
                      value: account.id,
                      child: Text(account.name),
                    );
                  }).toList(),
                ],
              ),
          ),
            Expanded(
              child: filteredActivities.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: filteredActivities.length,
                itemBuilder: (context, index) {
                  final Activity activity = filteredActivities[index];
                  return ListTile(
                    title: Text('${activity.type} - ${activity.amount} ${activity.currency}'),
                    subtitle: Text('${activity.category} on ${activity.date.toIso8601String()}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ActivityDetailsPage(
                              activity: activity, isNew: false, accountId: activity.accountId)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        ref.read(activityNotifierProvider.notifier).removeActivity(activity.id);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity deleted')));
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
