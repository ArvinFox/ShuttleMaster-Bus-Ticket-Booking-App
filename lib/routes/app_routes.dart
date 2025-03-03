import 'package:flutter/material.dart';
import 'package:shuttlemaster/routes/auth_routes.dart';
import 'package:shuttlemaster/routes/driver_routes.dart';
import 'package:shuttlemaster/routes/static_routes.dart';
import 'package:shuttlemaster/routes/student_routes.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    ...StaticRoutes.routes,
    ...AuthRoutes.routes,
    ...StudentRoutes.routes,
    ...DriverRoutes.routes,
  };
}