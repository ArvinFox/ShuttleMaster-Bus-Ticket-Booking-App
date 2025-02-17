import 'package:flutter/material.dart';

class CustomGreeting extends StatelessWidget {
  const CustomGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Welcome to ShuttleMaster!",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }
}