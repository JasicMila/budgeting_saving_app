import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budgeting_saving_app/src/views/sign_in_page.dart';
import 'package:budgeting_saving_app/src/views/main_screen.dart';
import 'package:budgeting_saving_app/src/services/auth_service.dart';
import 'package:budgeting_saving_app/src/notifiers/account_notifier.dart';
import 'package:budgeting_saving_app/src/notifiers/activity_notifier.dart';
import 'package:budgeting_saving_app/src/notifiers/category_notifier.dart';
import 'package:budgeting_saving_app/src/models/account.dart';
import 'package:budgeting_saving_app/src/models/activity.dart';
import 'package:budgeting_saving_app/src/models/category.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final accountNotifierProvider = StateNotifierProvider<AccountNotifier, List<Account>>((ref) => AccountNotifier(ref));
final activityNotifierProvider = StateNotifierProvider<ActivityNotifier, List<Activity>>((ref) => ActivityNotifier(ref));
final categoryNotifierProvider = StateNotifierProvider.family<CategoryNotifier, List<Category>, String>((ref, accountId) => CategoryNotifier(ref, accountId));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase with environment variables
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: dotenv.env['API_KEY']!,
        authDomain: dotenv.env['AUTH_DOMAIN']!,
        projectId: dotenv.env['PROJECT_ID']!,
        storageBucket: dotenv.env['STORAGE_BUCKET']!,
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
        appId: dotenv.env['APP_ID']!,
        measurementId: dotenv.env['MEASUREMENT_ID'],
      ),
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Budgeting & Savings App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.purple[800],
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the user is signed in
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while waiting for the authentication state
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          // User is signed in, show home page
          return const MainScreen();
        } else {
          // No user signed in, show sign-in page
          return const SignInPage();
        }
      },
    );
  }
}
