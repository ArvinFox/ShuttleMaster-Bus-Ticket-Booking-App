import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_auth_appbar.dart';
import 'package:shuttlemaster/components/custom_button.dart';
import 'package:shuttlemaster/components/custom_greeting.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class EnterIdScreen extends StatefulWidget {
  const EnterIdScreen({super.key});

  @override
  _EnterIdScreenState createState() => _EnterIdScreenState();
}

class _EnterIdScreenState extends State<EnterIdScreen> {
  final _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve user role
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String role = args?['role'] ?? "passenger";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAuthAppbar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                      ? "Please enter your Student ID or Lecturer ID here."
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
                        // TODO: Verify ID
                    
                        String route = "/select-otp-method";
                        if (role != "passenger") route = "/enter-otp";
                        
                        Navigator.pushNamed(
                          context, 
                          route,
                          arguments: {"role": role, "id": id},
                        );
                      } else {
                        Helpers.showMessage(context, 
                          role == "passenger" 
                            ? "ID is required" 
                            : "NIC is required",
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}