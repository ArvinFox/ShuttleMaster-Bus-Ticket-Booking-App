import 'package:flutter/material.dart';
import 'package:shuttlemaster/routes/app_routes.dart';
import 'package:shuttlemaster/screens/auth/welcome_screen.dart';
// import 'package:shuttlemaster/screens/driver/profile_screen.dart';
// import 'package:shuttlemaster/screens/student/profile_screen.dart';
// import 'package:shuttlemaster/screens/student/main_layout_screen.dart';

class ShuttleMaster extends StatelessWidget {
  const ShuttleMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ShuttleMaster",
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
      routes: AppRoutes.routes,
    );
  }
}
