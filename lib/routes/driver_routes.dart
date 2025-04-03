import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/main_layout_screen.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/screens/driver/profile_screen.dart';
import 'package:shuttlemaster/screens/driver/trip_history.dart';
import 'package:shuttlemaster/screens/driver/view_profile.dart';

class DriverRoutes {
  static Map<String, WidgetBuilder> routes = {
    // Add the driver's routes here
    '/driver/home': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final driverId = args?['driver_id'] as String?;

      return MainLayoutScreen(userRole: AppConfig.driverRole, driverId: driverId);
    },
    '/trip-history':(context) => TripHistory(),
    '/driver-profile':(context) => ProfileScreenDriver(),
    '/driver/view-profile': (context) => ViewProfileDriver()
  };
}