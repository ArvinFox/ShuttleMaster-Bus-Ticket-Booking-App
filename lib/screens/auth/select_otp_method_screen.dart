import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_auth_appbar.dart';
import 'package:shuttlemaster/components/custom_button.dart';
import 'package:shuttlemaster/components/custom_greeting.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/user_model.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/utils/formatters.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class SelectOtpMethodScreen extends StatefulWidget {
  const SelectOtpMethodScreen({super.key});

  @override
  _SelectOtpMethodScreenState createState() => _SelectOtpMethodScreenState();
}

class _SelectOtpMethodScreenState extends State<SelectOtpMethodScreen> {
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String id = args?['id'] ?? AppConfig.invalidId;
      final String role = args?['role'] ?? AppConfig.passengerRole;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null && !userProvider.isLoading) {
        await userProvider.fetchUser(id, role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

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

                if (userProvider.isLoading)
                  CircularProgressIndicator()
                else ...[
                  RadioListTile<String>(
                    title: Text(
                      "Mobile number: ${Formatters.getMaskedPhoneNumber(userProvider.user?.phone)}"
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
                      "Email address: ${Formatters.getMaskedEmail((userProvider.user as PassengerModel).email)}"
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
                      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                      final String id = args?['id'] ?? AppConfig.invalidId;
                      final String role = args?['role'] ?? AppConfig.passengerRole;

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