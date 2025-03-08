import 'package:flutter/material.dart';
import 'package:shuttlemaster/routes/app_routes.dart';
import 'package:shuttlemaster/screens/auth/enter_id_screen.dart';
// import 'package:shuttlemaster/screens/static/welcome_screen.dart';
// import 'package:shuttlemaster/screens/student/rides_screen_selection.dart';
import 'package:shuttlemaster/screens/student/main_layout_screen.dart';
import 'package:shuttlemaster/screens/student/view_profile.dart';

class ShuttleMaster extends StatelessWidget {
  const ShuttleMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ShuttleMaster",
      debugShowCheckedModeBanner: false,
      home: MainLayoutScreen(),
      routes: AppRoutes.routes,
    );
  }
}
