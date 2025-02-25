import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_auth_appbar.dart';
import 'package:shuttlemaster/components/custom_greeting.dart';
import 'package:shuttlemaster/services/otp_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({super.key});

  @override
  _EnterOtpScreenState createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final OtpService _otpService = OtpService();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false;
  int _remainingTime = 30;
  Timer? _timer;
  String? _generatedOtp;
  DateTime? _otpExpiryTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtp();
    });
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    if (isResend && _isOtpSent) {
      Helpers.showMessage(context, "Please wait $_remainingTime seconds before requesting another OTP.");
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // final String id = args?['id'] ?? "unknown";
    final String otpMethod = args?['otp-method'] ?? "mobile";

    String otp = Helpers.generateOtp();
    bool isSuccess = false;
      
    if (otpMethod == "email") {
      // TODO: String email = "";   // Get email via ID
      isSuccess = await _otpService.sendEmailOtp("uminduvh@gmail.com", otp);
    } else {
      // TODO: String phoneNumber = "";   // Get phone number via ID
      isSuccess = await _otpService.sendSMSOtp("+94741153063", otp);
    }

    if (isSuccess) {
      setState(() {
        _generatedOtp = otp;
        _otpExpiryTime = DateTime.now().add(Duration(minutes: 5));
        _isOtpSent = true;
        _remainingTime = 30;
      });

      _startTimer();

      Helpers.showMessage(context, "OTP sent to your $otpMethod.");

    } else if (isResend) {
      await Future.delayed(Duration(milliseconds: 250));
      Helpers.showMessage(context, "Failed to resend OTP. Please try again.");
    }
  }

  Future<bool> _verifyOtp(String enteredOtp) async {
    if (enteredOtp.isEmpty) {
      Helpers.showMessage(context, "Please enter OTP.");
      return false;
    }

    if (_generatedOtp == null || _otpExpiryTime == null) {
      await Future.delayed(Duration(seconds: 1));
      Helpers.showMessage(context, "OTP has expired. Please request a new one.");
      return false;
    }

    if (DateTime.now().isAfter(_otpExpiryTime!)) {
      await Future.delayed(Duration(seconds: 1));
      Helpers.showMessage(context, "OTP has expired. Please request a new one.");
      return false;
    }

    if (enteredOtp != _generatedOtp) {
      await Future.delayed(Duration(seconds: 1));
      Helpers.showMessage(context, "Invalid OTP. Please try again.");
      return false;
    }

    setState(() {
      _generatedOtp = null;
      _otpExpiryTime = null;
    });
    
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isOtpSent = false;
        });
      }
    });
  }

  Future<void> _handleOtpVerification() async {
    setState(() => _isLoading = true);
    bool isCorrectOtp = await _verifyOtp(_otpController.text);
    setState(() => _isLoading = false);

    if (isCorrectOtp) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String role = args?['role'] ?? "passenger";
      final String id = args?['id'] ?? "unknown";

      Navigator.pushNamedAndRemoveUntil(
        context,
        await getUserHomeRoute(role),
        (route) => false,
        arguments: {"id": id},
      );
    }
  }

  Future<String> getUserHomeRoute(String? role) async {
    await Future.delayed(Duration(milliseconds: 250));
    return (role == "passenger") ? "/student/home" : "/driver/home";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Retrieve user role, id, and otp method
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String otpMethod = args?['otp-method'] ?? "mobile";

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
        
                Text("Enter OTP here",style: TextStyle(fontSize: 15)),
                SizedBox(height: 20),
        
                _buildOtpInputField(otpMethod),
                SizedBox(height: 25),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _buildOtpInputField(String otpMethod) {
    return Column(
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
            _sendOtp(isResend: true);
          },
          child: Text(
            _isOtpSent
              ? "Resend OTP in $_remainingTime seconds"
              : "Resend OTP",
            style: TextStyle(
              fontSize: 12,
              color: _isOtpSent ? Colors.grey : const Color.fromARGB(223, 68, 137, 255),
            ),
          ),
        ),
      ],
    );
  }

  ElevatedButton _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading
        ? null
        : _handleOtpVerification,
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
    );
  }
}