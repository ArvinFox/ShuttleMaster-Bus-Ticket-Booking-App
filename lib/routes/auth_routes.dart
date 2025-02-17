import 'package:flutter/material.dart';
import 'package:shuttlemaster/screens/auth/enter_id_screen.dart';
import 'package:shuttlemaster/screens/auth/enter_otp_screen.dart';
import 'package:shuttlemaster/screens/auth/role_selection_screen.dart';
import 'package:shuttlemaster/screens/auth/select_otp_method_screen.dart';
import 'package:shuttlemaster/screens/auth/welcome_screen.dart';

class AuthRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/welcome': (context) => WelcomeScreen(),
    '/select-role': (context) => RoleSelectionScreen(),
    '/enter-id': (context) => EnterIdScreen(),
    '/select-otp-method': (context) => SelectOtpMethodScreen(),
    '/enter-otp': (context) => EnterOtpScreen(),
  };
}