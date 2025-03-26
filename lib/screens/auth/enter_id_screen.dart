import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_auth_appbar.dart';
import 'package:shuttlemaster/components/custom_auth_id_input_formatter.dart';
import 'package:shuttlemaster/components/custom_button.dart';
import 'package:shuttlemaster/components/custom_greeting.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class EnterIdScreen extends StatefulWidget {
  const EnterIdScreen({super.key});

  @override
  State<EnterIdScreen> createState() => _EnterIdScreenState();
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
    final String role = args?['role'] ?? AppConfig.passengerRole;

    final userProvider = Provider.of<UserProvider>(context);

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
                    
                  TextFormField(
                    controller: _idController,
                    keyboardType: role == AppConfig.passengerRole
                      ? TextInputType.number
                      : TextInputType.text,
                    maxLength: role == AppConfig.passengerRole ? 8 : 12,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(role == AppConfig.passengerRole ? 8 : 12),
                      CustomAuthIdInputFormatter(role),
                    ],
                    decoration: InputDecoration(
                      labelText: role == AppConfig.passengerRole
                        ? "Student ID/Lecturer ID"
                        : "National Identity Card (NIC)",
                      border: OutlineInputBorder(),
                      counterText: "",
                    ),
                  ),
                  SizedBox(height: 30),
                    
                  CustomButton(
                    label: "Continue",
                    isLoading: userProvider.isLoading,
                    onPressed: userProvider.isLoading ? null : () async {
                      String id = _idController.text.trim();

                      if (id.isNotEmpty) {
                        // Validate ID
                        bool isValid = false;
                        if (role == AppConfig.passengerRole) {
                          isValid = RegExp(r'^\d{5}$|^\d{8}$').hasMatch(id);
                        } else {
                          isValid = RegExp(r'^\d{9}[VXvx]$|^\d{12}$').hasMatch(id);
                        }

                        if (!isValid) {
                          Helpers.showMessage(
                            context, 
                            role == AppConfig.passengerRole
                              ? "Invalid Student/Lecturer ID"
                              : "Invalid NIC"
                          );
                          return;
                        }

                        // Process if valid
                        await userProvider.fetchUser(id, role);

                        if (userProvider.user == null) {
                          String message = role == AppConfig.passengerRole
                            ? "Passenger not found. Please check your NSBM ID."
                            : "Driver not found. Please check your NIC.";

                          Helpers.showMessage(context, message);
                          return;
                        }
                    
                        String route = "/select-otp-method";
                        if (role != AppConfig.passengerRole) route = "/enter-otp";
                      
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