import 'package:flutter/material.dart';
import 'package:shuttlemaster/screens/student/main_layout_screen.dart';
import 'package:shuttlemaster/screens/student/profile_screen.dart';
import 'package:shuttlemaster/screens/student/traveling_history.dart';

class StudentRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/student/home': (context) => MainLayoutScreen(),
    '/traveling-history':(context) => TravelingHistory(initialIndex: 0, page: 'profile',),
    '/user-profile':(context) => ProfileScreenStuent(),
    '/cancel-booking':(context) => TravelingHistory(initialIndex: 0, page: 'home',),
    '/pay-later':(context) => TravelingHistory(initialIndex: 3, page: 'pay-later',),
    // Add the rest of the student's routes here
  };
}