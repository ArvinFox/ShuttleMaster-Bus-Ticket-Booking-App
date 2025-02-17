import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_auth_appbar.dart';
import 'package:shuttlemaster/components/custom_greeting.dart';

class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({super.key});

  @override
  _EnterOtpScreenState createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isOtpSent = false;

  @override
  Widget build(BuildContext context) {
    // Retrieve user role, id, and otp method
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String role = args?['role'] ?? "passenger";
    final String id = args?['id'] ?? 'unknown';
    final String otpMethod = args?['otp-method'] ?? "mobile";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAuthAppbar(),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 60,
            top: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomGreeting(),
              SizedBox(height: 20),

              Image.asset("assets/images/role-select.png", height: 200),
              SizedBox(height: 30),

              Text(
                "Enter OTP here",
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "OTP",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      resendOtp(otpMethod);
                    },
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                        fontSize: 12,
                        color: _isOtpSent ? Colors.grey : Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),

              ElevatedButton(
                onPressed: _isLoading
                  ? null
                  : () async {
                    String enteredOtp = _otpController.text;

                    if (enteredOtp.isNotEmpty) {
                      setState(() {
                        _isLoading = true;
                      });

                      bool isCorrectOtp = await verifyOtp(enteredOtp);
                      setState(() {
                        _isLoading = false;
                      });

                      if (isCorrectOtp) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          await getUserHomeRoute(role),
                          (route) => false,
                          arguments: {"id": id},
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Incorrect OTP")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter OTP")),
                        );
                    }
                  },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Color.fromARGB(255, 219, 232, 255),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ), 
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Placeholder functions
  Future<bool> verifyOtp(String enteredOtp) async {
    await Future.delayed(Duration(seconds: 2));
    return enteredOtp == "123456";
  }

  Future<String> getUserHomeRoute(String? role) async {
    await Future.delayed(Duration(milliseconds: 250));
    return (role == "passenger") ? "/student/home" : "/driver/home";
  }

  Future<void> resendOtp(String otpMethod) async {
    if (!_isOtpSent) {
      // TODO: Send OTP

      setState(() {
        _isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP sent to your $otpMethod")),
      );

      await Future.delayed(Duration(seconds: 30));
      setState(() {
        _isOtpSent = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please wait 30 seconds before requesting another OTP.")),
      );
    }
  }
}