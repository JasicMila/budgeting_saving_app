import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/activity_service.dart';
import 'activity_details_page.dart';
import 'package:budgeting_saving_app/src/models/activity.dart';

class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ActivityDetailsPage(isNew: true)),
            ),
          ),
        ],
      ),
      body: Consumer<ActivityService>(
        builder: (context, activityService, child) {
          var activities = activityService.activities;
          if (activityService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              Activity activity = activities[index];
              return ListTile(
                title: Text('${activity.type} - ${activity.amount} ${activity.currency}'),
                subtitle: Text('${activity.category} on ${activity.date}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityDetailsPage(activity: activity, isNew: false)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    activityService.deleteActivity(activity.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
