import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_auth_appbar.dart';
import 'package:shuttlemaster/components/custom_button.dart';
import 'package:shuttlemaster/components/custom_greeting.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/user_model.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/services/otp_service.dart';
import 'package:shuttlemaster/utils/formatters.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({super.key});

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final _otpController = TextEditingController();
  final _otpService = OtpService();

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
    final String id = args?['id'] ?? AppConfig.invalidId;
    final String role = args?['role'] ?? AppConfig.passengerRole;
    final String otpMethod = args?['otp-method'] ?? AppConfig.otpPhone;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null && !userProvider.isLoading) {
      await userProvider.fetchUser(id, role);
    }
    final contactInfo = (otpMethod == AppConfig.otpEmail)
      ? (userProvider.user as PassengerModel).email
      : userProvider.user?.phone;

    String otp = Helpers.generateOtp();
    bool isSuccess = otpMethod == AppConfig.otpEmail
      ? await _otpService.sendEmailOtp(contactInfo!, otp)
      : await _otpService.sendSMSOtp(contactInfo!, otp);

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

  Future<void> _handleOtpVerification(String? driverId) async {
    setState(() => _isLoading = true);
    bool isCorrectOtp = await _verifyOtp(_otpController.text);
    setState(() => _isLoading = false);

    if (isCorrectOtp) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String role = args?['role'] ?? AppConfig.passengerRole;

      Navigator.pushNamedAndRemoveUntil(
        context,
        (await getUserHomeRoute(role, driverId))["route"] as String,
        (route) => false,
        arguments: (await getUserHomeRoute(role, driverId))["arguments"],
      );
    }
  }

  Future<Map<String, dynamic>> getUserHomeRoute(String? role, String? driverId) async {
    await Future.delayed(Duration(milliseconds: 250));
    if (role == AppConfig.passengerRole) {
      return {"route": "/student/home", "arguments": null};
    } else {
      return {"route": "/driver/home", "arguments": {'driver_id': driverId}};
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Retrieve user role, id, and otp method
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String otpMethod = args?['otp-method'] ?? AppConfig.otpPhone;

    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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

                if (userProvider.isLoading)
                  CircularProgressIndicator()
                else ...[
                  Text(
                    "We've sent an OTP to your $otpMethod (${otpMethod == AppConfig.otpEmail ? Formatters.getMaskedEmail((userProvider.user as PassengerModel).email) : Formatters.getMaskedPhoneNumber(userProvider.user?.phone)}). \nEnter it below to continue.",
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
          
                  _buildOtpInputField(theme),
                  SizedBox(height: 25),

                  CustomButton(
                    label: "Continue", 
                    onPressed: _isLoading ? null : () async {
                      await _handleOtpVerification(userProvider.user!.userId);
                    },
                    isLoading: _isLoading,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column _buildOtpInputField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            labelText: "OTP",
            border: OutlineInputBorder(),
            counterText: "",
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
              color: _isOtpSent ? theme.disabledColor : const Color.fromARGB(223, 68, 137, 255),
            ),
          ),
        ),
      ],
    );
  }
}