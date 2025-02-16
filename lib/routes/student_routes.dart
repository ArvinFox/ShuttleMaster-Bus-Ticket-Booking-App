import 'package:flutter/material.dart';
import 'package:shuttlemaster/screens/student/main_layout_screen.dart';

class StudentRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/student/home': (context) => MainLayoutScreen(),
    // Add the rest of the student's routes here
  };
}