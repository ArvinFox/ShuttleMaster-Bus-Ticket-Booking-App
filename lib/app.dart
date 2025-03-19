import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/providers/rides_provider.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/routes/app_routes.dart';
import 'package:shuttlemaster/screens/static/welcome_screen.dart';
import 'package:shuttlemaster/screens/student/rides_booking_monthly.dart';
import 'package:shuttlemaster/screens/student/rides_screen.dart';
import 'package:shuttlemaster/screens/student/topup_screen.dart';
// import 'package:shuttlemaster/screens/static/splash_screen.dart';

class ShuttleMaster extends StatelessWidget {
  const ShuttleMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RidesProvider()),
      ],
      child: MaterialApp(
        title: "ShuttleMaster",
        debugShowCheckedModeBanner: false,
        home: WelcomeScreen(),
        // initialRoute: "/intro",
        routes: AppRoutes.routes,
      ),
    );
  }
}
