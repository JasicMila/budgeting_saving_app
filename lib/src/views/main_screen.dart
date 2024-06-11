import 'package:budgeting_saving_app/src/views/activities_page.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'accounts_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budgeting App'),
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