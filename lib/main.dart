import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shuttlemaster/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print("----12345677777777777777777777777------------------------------");
    await Firebase.initializeApp();
  } catch (e) {
    print("error:$e");
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
