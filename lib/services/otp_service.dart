import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shuttlemaster/constants/app_credentials.dart';
import 'package:shuttlemaster/utils/helpers.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class OtpService {
  final _email = AppCredentials.smtpEmail;
  final _appPassword = AppCredentials.smtpAppPassword;
  final _accountSid = AppCredentials.twilioAccountSid;
  final _authToken = AppCredentials.twilioAuthToken;
  final _twilioNumber = AppCredentials.twilioPhoneNumber;

  Future<bool> sendEmailOtp(String email, String otp) async {
    final smtpServer = gmail(_email, _appPassword);

    final message = Message()
      ..from = Address(_email, "ShuttleMaster OTP Service")
      ..recipients.add(email)
      ..subject = "ShuttleMaster OTP Verification"
      ..text = "Your ShuttleMaster verification code is: $otp."
                "It will expire in 5 minutes. Do not share this code with anyone.";
    
    try {
      final sendReport = await send(message, smtpServer);
      Helpers.debugPrintWithBorder("OTP sent successfully via email ($email): ${sendReport.toString()}");
      return true;
      
    } catch (e) {
      Helpers.debugPrintWithBorder("Failed to send OTP via email: $e");
      return false;
    }
  }

  Future<bool> sendSMSOtp(String phoneNumber, String otp) async {
    final TwilioFlutter twilio = TwilioFlutter(
      accountSid: _accountSid,
      authToken: _authToken,
      twilioNumber: _twilioNumber,
    );

    try {
      await twilio.sendSMS(
        toNumber: phoneNumber,
        messageBody: "ShuttleMaster OTP: $otp. Valid for 5 minutes. Do not share this code with anyone."
      );
      Helpers.debugPrintWithBorder("OTP sent successfully via SMS ($phoneNumber)");
      return true;

    } catch (e) {
      Helpers.debugPrintWithBorder("Failed to send OTP via SMS: $e");
      return false;
    }
  }
}