import 'package:flutter/material.dart';
import 'package:shuttlemaster/screens/student/home_screen.dart';
import 'package:shuttlemaster/screens/student/rides_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  _MainLayoutScreenState createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    RidesScreen(),
    // Add the other navigation screens here (Notifications, Account)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_selectedIndex != 0) {
            setState(() {
              _selectedIndex = 0;
            });
          }
        }
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: "Rides"),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
            ],
          ),
        ),
      ),
    );
  }
}