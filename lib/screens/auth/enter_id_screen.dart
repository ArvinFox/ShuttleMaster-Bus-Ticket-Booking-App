import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_auth_appbar.dart';
import 'package:shuttlemaster/components/custom_button.dart';
import 'package:shuttlemaster/components/custom_greeting.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/user_model.dart';
import 'package:shuttlemaster/services/user_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class EnterIdScreen extends StatefulWidget {
  const EnterIdScreen({super.key});

  @override
  _EnterIdScreenState createState() => _EnterIdScreenState();
}

class _EnterIdScreenState extends State<EnterIdScreen> {
  final _idController = TextEditingController();
  final _userService = UserService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve user role
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String role = args?['role'] ?? AppConfig.passengerRole;

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
                    
                  Image.asset("assets/images/common-image.png", height: 200),
                  SizedBox(height: 30),
                    
                  Text(
                    role == AppConfig.passengerRole
                      ? "Please enter your Student ID or Lecturer ID here."
                      : "Please enter your National Identity Card Number here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 20),
                    
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: role == AppConfig.passengerRole
                        ? "Student ID/Lecturer ID"
                        : "National Identity Card (NIC)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 30),
                    
                  CustomButton(
                    label: "Continue",
                    isLoading: _isLoading,
                    onPressed: () async {
                      String id = _idController.text;
                    
                      if (id.isNotEmpty) {
                        setState(() {
                          _isLoading = true;
                        });

                        UserModel? user = await _userService.getUserById(id, role);

                        if (user == null) {
                          String message = role == AppConfig.passengerRole
                            ? "Passenger not found. Please check your NSBM ID."
                            : "Driver not found. Please check your NIC.";
                          
                          await Future.delayed(Duration(milliseconds: 750));
                          setState(() {
                            _isLoading = false;
                          });

                          Helpers.showMessage(context, message);
                          return;
                        }
                    
                        String route = "/select-otp-method";
                        if (role != AppConfig.passengerRole) route = "/enter-otp";

                        await Future.delayed(Duration(seconds: 1));
                        setState(() {
                          _isLoading = false;
                        });
                        
                        Navigator.pushNamed(
                          context, 
                          route,
                          arguments: {"role": role, "id": id},
                        );
                      } else {
                        Helpers.showMessage(context, 
                          role == AppConfig.passengerRole 
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