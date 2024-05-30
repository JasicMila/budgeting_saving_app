
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import '../providers/firestore_service_provider.dart';
import '../services/firestore_service.dart';

class ActivityNotifier extends StateNotifier<List<Activity>> {
  final Ref ref;

  FirestoreService<Activity> get _firestoreService => ref.read(firestoreActivityServiceProvider);

  ActivityNotifier(this.ref) : super([]) {
    fetchActivities();  // Fetch all activities when the notifier is initialized
  }

  Future<void> fetchActivities([String? accountId]) async {
    try {
      var activities = await _firestoreService.fetchAll();
      // If accountId is provided, filter activities by that accountId.
      if (accountId != null && accountId.isNotEmpty) {
        activities = activities.where((activity) => activity.accountId == accountId).toList();
      }
      state = activities;
    } catch (e) {
      print("Error fetching activities: $e");
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      await _firestoreService.create(activity.toMap(), activity.id);
      state = [...state, activity];
    } catch (e) {
      print("Error adding activity: $e");
    }
  }

  Future<void> removeActivity(String activityId) async {
    try {
      await _firestoreService.delete(activityId);
      state = state.where((activity) => activity.id != activityId).toList();
    } catch (e) {
      print("Error removing activity: $e");
    }
  }

  Future<void> updateActivity(String activityId, Activity updatedActivity) async {
    try {
      await _firestoreService.update(activityId, updatedActivity.toMap());
      state = state.map((activity) => activity.id == activityId ? updatedActivity : activity).toList();
    } catch (e) {
      print("Error updating activity: $e");
    }
  }
}
