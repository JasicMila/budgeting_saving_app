import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import '../notifiers/activity_notifier.dart';
import '../services/firestore_service.dart';
import 'firestore_service_provider.dart';

// Provider for managing activities
final activityNotifierProvider = StateNotifierProvider<ActivityNotifier, List<Activity>>((ref) {
  FirestoreService<Activity> service = ref.read(firestoreActivityServiceProvider);
  return ActivityNotifier(ref);
});
