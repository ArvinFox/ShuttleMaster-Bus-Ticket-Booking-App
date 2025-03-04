import 'package:flutter/material.dart';
import 'package:shuttlemaster/screens/student/main_layout_screen.dart';
import 'package:shuttlemaster/screens/student/profile_screen.dart';
import 'package:shuttlemaster/screens/student/rides_booking.dart';
import 'package:shuttlemaster/screens/student/rides_booking_monthly.dart';
import 'package:shuttlemaster/screens/student/traveling_history.dart';
import 'package:shuttlemaster/screens/student/rides_screen_selection.dart';

class StudentRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/student/home': (context) => MainLayoutScreen(),
    '/traveling-history':(context) => TravelingHistory(initialIndex: 0, page: 'profile',),
    '/user-profile':(context) => ProfileScreenStuent(),
    '/cancel-booking':(context) => TravelingHistory(initialIndex: 0, page: 'home',),
    '/pay-later':(context) => TravelingHistory(initialIndex: 3, page: 'pay-later',),
    '/privateBusScreen' : (context) => RidesScreenSelection(busType: 'Private Bus',),
    '/NSBM-Bus' : (context) => RidesScreenSelection(busType: 'NSBM Bus',),
    '/public-transport' : (context) => RidesScreenSelection(busType: 'Public Transport',),
    '/book-now' : (context) => BookingScreen(),
    '/monthly-book' : (context) => RidesScreenMonthly(),
    // Add the rest of the student's routes here
  };
}