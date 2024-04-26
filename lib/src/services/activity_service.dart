import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgeting_saving_app/src/models/activity.dart';

class ActivityService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Activity> _activities = [];
  bool _isLoading = false;

  ActivityService(){
    fetchActivities(); // Fetch activities on initialization
  }

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;

  Future<void> fetchActivities() async {
    _isLoading = true;
    notifyListeners();
    try {
      final QuerySnapshot activitySnapshot = await _firestore
          .collection('activities')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      _activities = activitySnapshot.docs
          .map((doc) => Activity.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      print(_activities);
      notifyListeners();  // Notify widgets of state change
    } catch (e) {
      // Handle exceptions by logging or re-throwing
      print("Error fetching activities: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new activity
  Future<void> addActivity(Activity activity) async {
    try {
      print("Adding activity: ${activity.category}");
      await _firestore.collection('activities').add(activity.toMap());
      activities.add(activity);
      notifyListeners();
      print("Activity added successfully");
    } catch (e) {
      print("Error adding activity: $e");
    }
  }
  // Update an existing activity
  Future<void> updateActivity(Activity activity) async {
    try {
      print("Editing activity: ${activity.category}");
      await _firestore.collection('activities').doc(activity.id).update(activity.toMap());
      int index = activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        activities[index] = activity;
        notifyListeners();
      }
      print("Activity edited successfully");
    } catch (e) {
      print("Error editing activity: $e");
    }
  }
  // Delete an activity
  Future<void> deleteActivity(String activityId) async {
    try {
      print("Deleting activity: $activityId");
      await _firestore.collection('activities').doc(activityId).delete();
      activities.removeWhere((a) => a.id == activityId);
      notifyListeners();
      print("Activity deleted successfully");
    } catch (e) {
      print("Error deleting activity: $e");
    }

  }
}
