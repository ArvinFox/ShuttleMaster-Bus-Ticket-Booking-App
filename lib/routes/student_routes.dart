import 'package:flutter/material.dart';
import 'package:shuttlemaster/screens/student/main_layout_screen.dart';
import 'package:shuttlemaster/screens/student/profile_screen.dart';
import 'package:shuttlemaster/screens/student/rides_booking.dart';
import 'package:shuttlemaster/screens/student/rides_booking_monthly.dart';
import 'package:shuttlemaster/screens/student/topup_screen.dart';
import 'package:shuttlemaster/screens/student/total_payable.dart';
import 'package:shuttlemaster/screens/student/traveling_history.dart';
import 'package:shuttlemaster/screens/student/rides_screen_selection.dart';
import 'package:shuttlemaster/screens/student/view_profile.dart';

class StudentRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/student/home': (context) => MainLayoutScreen(),
    '/student/view-profile': (context) => ViewProfileStudent(),
    '/traveling-history':(context) => TravelingHistory(initialIndex: 0),
    '/view-traveling-history':(context) => TravelingHistory(initialIndex: 1),
    '/pay-later':(context) => TravelingHistory(initialIndex: 3),
    '/user-profile':(context) => ProfileScreenStuent(),
    '/privateBusScreen' : (context) => RidesScreenSelection(busType: 'Private Bus',),
    '/NSBM-Bus' : (context) => RidesScreenSelection(busType: 'NSBM Bus',),
    '/public-transport' : (context) => RidesScreenSelection(busType: 'Public Transport',),
    '/book-now' : (context) => BookingScreen(),
    '/monthly-book' : (context) => RidesScreenMonthly(),
    '/total-payable': (context) => TotalPayableScreen(),
    '/top-up-account': (context) => TopUpScreen()
    // Add the rest of the student's routes here
  };
}