import 'package:flutter/material.dart';
import 'package:shuttlemaster/screens/static/about_us_screen.dart';
import 'package:shuttlemaster/screens/static/privacy_policy_screen.dart';
import 'package:shuttlemaster/screens/static/welcome_screen.dart';

class StaticRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/welcome': (context) => WelcomeScreen(),
    '/about-us': (context) => AboutUsScreen(),
    '/privacy-policy': (context) => PrivacyPolicyScreen(),
  };
}