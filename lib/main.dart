
import 'package:budgeting_saving_app/src/services/account_service.dart';
import 'package:budgeting_saving_app/src/services/activity_service.dart';
import 'package:budgeting_saving_app/src/services/category_service.dart';
import 'package:budgeting_saving_app/src/views/screens/sign_in_page.dart';
import 'package:budgeting_saving_app/src/views/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load environment variables

  // Initialize Firebase with environment variables
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['API_KEY']!, // Load from .env file
      authDomain: dotenv.env['AUTH_DOMAIN']!, // Load from .env file
      projectId: dotenv.env['PROJECT_ID']!, // Load from .env file
      storageBucket: dotenv.env['STORAGE_BUCKET']!, // Load from .env file
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!, // Load from .env file
      appId: dotenv.env['APP_ID']!, // Load from .env file
      measurementId: dotenv.env['MEASUREMENT_ID'], // Load from .env file
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountService()),
        ChangeNotifierProvider(create: (_) => ActivityService()),
        ChangeNotifierProvider(create: (_) => CategoryService()),
        // Add other providers here as needed
      ],
      child: MaterialApp(
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
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the user is signed in
        if (snapshot.hasData) {
          return const MainScreen(); // User is signed in, show home page
        } else {
          return const SignInPage(); // No user signed in, show sign-in page
        }
      },
    );
  }
}
