import 'package:flutter/material.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/screens/driver/driver_home_screen.dart';
import 'package:shuttlemaster/screens/driver/driver_notification_screen.dart';
import 'package:shuttlemaster/screens/driver/profile_screen.dart';
import 'package:shuttlemaster/screens/driver/trip_info_screen.dart';
import 'package:shuttlemaster/screens/student/home_screen.dart';
import 'package:shuttlemaster/screens/student/notification_screen.dart';
import 'package:shuttlemaster/screens/student/profile_screen.dart';
import 'package:shuttlemaster/screens/student/rides_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  final String userRole;
  final String? driverId;

  const MainLayoutScreen({super.key, required this.userRole, this.driverId});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;
  late final List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();

    if (widget.userRole == AppConfig.passengerRole) {
      _screens = [
        HomeScreen(),
        RidesScreen(),
        StudentNotificationScreen(),
        ProfileScreenStuent(),
      ];

      _navItems = [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: "Rides"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
      ];
    } else if (widget.userRole == AppConfig.driverRole) {
      _screens = [
        DriverHomeScreen(),
        TripInfoScreen(driverId: widget.driverId!,),
        DriverNotificationScreen(),
        ProfileScreenDriver(),
      ];

      _navItems = [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: "Trip Info"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
            showSelectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: _navItems,
          ),
        ),
      ),
    );
  }
}