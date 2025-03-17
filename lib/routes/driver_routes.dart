import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/main_layout_screen.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/screens/driver/profile_screen.dart';
import 'package:shuttlemaster/screens/driver/trip_history.dart';
import 'package:shuttlemaster/screens/driver/view_profile.dart';

class DriverRoutes {
  static Map<String, WidgetBuilder> routes = {
    // Add the driver's routes here
    '/driver/home': (context) => MainLayoutScreen(userRole: AppConfig.driverRole),
    '/trip-history':(context) => TripHistory(),
    '/driver-profile':(context) => ProfileScreenDriver(),
    '/driver/view-profile': (context) => ViewProfileDriver()
  };
}