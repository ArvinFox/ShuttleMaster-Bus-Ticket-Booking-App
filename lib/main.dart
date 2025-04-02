import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shuttlemaster/app.dart';
import 'package:shuttlemaster/utils/helpers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    Helpers.debugPrintWithBorder("Error initializing Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShuttleMaster();
  }
}
