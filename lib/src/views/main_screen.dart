// lib/src/views/main_screen.dart
import 'package:budgeting_saving_app/src/views/activities_page.dart';
import 'package:flutter/material.dart';
import '../providers/providers.dart';
import 'home_page.dart';
import 'accounts_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/gradient_background_scaffold.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    final List<Widget> widgetOptions = <Widget>[
      const HomePage(),
      const AccountsPage(),
      const ActivitiesPage(),
    ];

    void onItemTapped(int index) {
      ref.read(selectedIndexProvider.notifier).state = index;
    }

    // Listen to auth state changes
    ref.listen<AsyncValue<User?>>(
      authStateChangesProvider,
      (previous, next) {
        if (next.value != null) {
          ref.read(accountNotifierProvider.notifier).fetchAccounts();
          ref.read(activityNotifierProvider.notifier).fetchActivities();
          // Fetch user details when signed in
          ref.refresh(userProvider);
        } else {
          // Handle user signed out logic if needed
          ref.read(accountNotifierProvider.notifier).clearAccounts();
          ref.read(activityNotifierProvider.notifier).clearActivities();
        }
      },
    );

    // Fetch the current user's details
    final userAsyncValue = ref.watch(userProvider);

    return GradientBackgroundScaffold(
      appBar: AppBar(
        title: userAsyncValue.when(
          data: (user) => Text('${user?.displayName ?? 'My'} Budgeting and Savings App'),
          loading: () => const Text('Loading...'),
          error: (err, stack) => Text('Error: $err'),
        ),
        backgroundColor: Colors.transparent, // Make AppBar background transparent
        elevation: 0,
      ),
      body: Center(
        child: widgetOptions.elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_max_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Activities',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.purple[800],
        onTap: onItemTapped,
      ),
    );
  }
}
