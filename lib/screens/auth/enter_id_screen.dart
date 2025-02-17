import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_auth_appbar.dart';
import 'package:shuttlemaster/components/custom_button.dart';
import 'package:shuttlemaster/components/custom_greeting.dart';

class EnterIdScreen extends StatefulWidget {
  const EnterIdScreen({super.key});

  @override
  _EnterIdScreenState createState() => _EnterIdScreenState();
}

class _EnterIdScreenState extends State<EnterIdScreen> {
  final _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Retrieve user role
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String role = args?['role'] ?? "passenger";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAuthAppbar(),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
            top: 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomGreeting(),
              SizedBox(height: 20),

              Image.asset("assets/images/role-select.png", height: 200),
              SizedBox(height: 30),

              Text(
                role == "passenger"
                  ? "Please enter your Student ID or Leturer ID here."
                  : "Please enter your National Identity Card Number here.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),

              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: role == "passenger"
                    ? "Student ID/Lecturer ID"
                    : "National Identity Card (NIC)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),

              CustomButton(
                label: "Continue",
                onPressed: () {
                  String id = _idController.text;

                  if (id.isNotEmpty) {
                    // TODO: Verify ID (and send OTP if role == 'bus driver')

                    String route = "/select-otp-method";
                    if (role != "passenger") route = "/enter-otp";
                    
                    Navigator.pushNamed(
                      context, 
                      route,
                      arguments: {"role": role, "id": id},
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                        role == "passenger"
                          ? "ID is required"
                          : "NIC is required",
                      )),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}