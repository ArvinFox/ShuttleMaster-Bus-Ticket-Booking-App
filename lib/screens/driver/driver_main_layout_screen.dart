import 'package:flutter/material.dart';
import 'package:shuttlemaster/screens/driver/driver_home_screen.dart';
import 'package:shuttlemaster/screens/driver/driver_notification_screen.dart';
import 'package:shuttlemaster/screens/driver/profile_screen.dart';
import 'package:shuttlemaster/screens/student/rides_screen.dart';

class DriverMainLayoutScreen extends StatefulWidget {
  const DriverMainLayoutScreen({super.key});

  @override
  _DriverMainLayoutScreenState createState() => _DriverMainLayoutScreenState();
}

class _DriverMainLayoutScreenState extends State<DriverMainLayoutScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    DriverHomeScreen(),
    RidesScreen(),
    DriverNotificationScreen(), // Add Notification Page here
    ProfileScreenDriver(),
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.directions_bus), label: "Trip Info"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: "Notifications"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "Account"),
            ],
          ),
        ),
      ),
    );
  }
}
