import 'package:flutter/material.dart';
import 'package:shuttlemaster/screens/driver/profile_screen.dart';
import 'package:shuttlemaster/screens/driver/trip_history.dart';

class DriverRoutes {
  static Map<String, WidgetBuilder> routes = {
    // Add the driver's routes here
    '/trip-history':(context) => TripHistory(),
    '/driver-profile':(context) => ProfileScreenDriver(),
  };
}