import 'package:budgeting_saving_app/src/views/activities_page.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'accounts_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _selectedAccountId = ''; // State variable to hold the selected account ID


  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const AccountsPage(),
    const SizedBox(), // Placeholder for ActivitiesPage
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to select an account and navigate to ActivitiesPage
  void selectAccountAndNavigate(String accountId) {
    setState(() {
      _selectedAccountId = accountId;
      _selectedIndex = 2; // Navigate to Activities tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budgeting App'),
      ),
      body: Center(
        child: _selectedIndex == 2
            ? ActivitiesPage(accountId: _selectedAccountId)
            : _widgetOptions.elementAt(_selectedIndex),
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple[800],
        onTap: _onItemTapped,
      ),
    );
  }
}