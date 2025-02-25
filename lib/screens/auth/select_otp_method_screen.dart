import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_auth_appbar.dart';
import 'package:shuttlemaster/components/custom_button.dart';
import 'package:shuttlemaster/components/custom_greeting.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class SelectOtpMethodScreen extends StatefulWidget {
  const SelectOtpMethodScreen({super.key});

  @override
  _SelectOtpMethodScreenState createState() => _SelectOtpMethodScreenState();
}

class _SelectOtpMethodScreenState extends State<SelectOtpMethodScreen> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    // Retrieve user role and id
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String role = args?['role'] ?? "passenger";
    final String id = args?['id'] ?? "unknown";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAuthAppbar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 60,
              top: 15,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomGreeting(),
                SizedBox(height: 20),
        
                Image.asset("assets/images/role-select.png", height: 200),
                SizedBox(height: 30),
        
                Text(
                  "You can get an OTP via your registered mobile number or email address.",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
        
                RadioListTile<String>(
                  title: Text("Mobile number: 07xxxxx989"),
                  value: 'mobile',
                  groupValue: _selectedMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text("Email address: xxxxx@students.nsbm.ac.lk"),
                  value: 'email',
                  groupValue: _selectedMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value;
                    });
                  },
                ),
                SizedBox(height: 30),
        
                CustomButton(
                  label: "Continue",
                  onPressed: () {
                    if (_selectedMethod != null) {
                      Navigator.pushNamed(
                        context,
                        '/enter-otp',
                        arguments: {
                          "role": role, 
                          "id": id, 
                          "otp-method": _selectedMethod,
                        },
                      );
                    } else {
                      Helpers.showMessage(context, "Please select an OTP verification method");
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}