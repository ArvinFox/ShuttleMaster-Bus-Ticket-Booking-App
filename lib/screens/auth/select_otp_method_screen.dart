import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_auth_appbar.dart';
import 'package:shuttlemaster/components/custom_button.dart';
import 'package:shuttlemaster/components/custom_greeting.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/user_model.dart';
import 'package:shuttlemaster/services/user_service.dart';
import 'package:shuttlemaster/utils/formatters.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class SelectOtpMethodScreen extends StatefulWidget {
  const SelectOtpMethodScreen({super.key});

  @override
  _SelectOtpMethodScreenState createState() => _SelectOtpMethodScreenState();
}

class _SelectOtpMethodScreenState extends State<SelectOtpMethodScreen> {
  final _userService = UserService();
  
  String? _selectedMethod;
  String? _phone;
  String? _email;
  bool _isLoading = true;

  Future<void> _fetchUserInfo(String id, String role) async {
    try {
      String phone = await _getUserContactInfo(AppConfig.otpPhone, id, role);
      String email = await _getUserContactInfo(AppConfig.otpEmail, id, role);

      setState(() {
        _phone = phone;
        _email = email;
        _isLoading = false;
      });

    } catch (e) {
      Helpers.showMessage(context, "Failed to load user information. Please try again.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getUserContactInfo(String contactType, String id, String role) async {
    PassengerModel? user = (await _userService.getUserById(id, role)) as PassengerModel?;

    if (user == null) throw Exception("User not found");

    switch (contactType) {
      case AppConfig.otpPhone:
        return Formatters.formatPhoneNumber(user.phone);
      case AppConfig.otpEmail:
        return user.email;
      default:
        throw Exception("Invalid contact type: $contactType");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve user role and id
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String id = args?['id'] ?? AppConfig.invalidId;
    final String role = args?['role'] ?? AppConfig.passengerRole;

    _fetchUserInfo(id, role);

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
        
                Image.asset("assets/images/common-image.png", height: 200),
                SizedBox(height: 30),
        
                Text(
                  "You can get an OTP via your registered mobile number or email address.",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),

                if (_isLoading)
                  CircularProgressIndicator()
                else ...[
                  RadioListTile<String>(
                    title: Text(
                      "Mobile number: ${Formatters.getMaskedPhoneNumber(_phone!)}"
                    ),
                    value: AppConfig.otpPhone,
                    groupValue: _selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedMethod = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(
                      "Email address: ${Formatters.getMaskedEmail(_email!)}"
                    ),
                    value: AppConfig.otpEmail,
                    groupValue: _selectedMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedMethod = value;
                      });
                    },
                  ),
                ],
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