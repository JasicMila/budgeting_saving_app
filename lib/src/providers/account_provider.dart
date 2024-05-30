import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../notifiers/account_notifier.dart';
import '../services/firestore_service.dart';
import 'firestore_service_provider.dart';

// Provider for managing accounts
final accountNotifierProvider = StateNotifierProvider<AccountNotifier, List<Account>>((ref) {
  FirestoreService<Account> service = ref.read(firestoreAccountServiceProvider);
  return AccountNotifier(ref);
});
