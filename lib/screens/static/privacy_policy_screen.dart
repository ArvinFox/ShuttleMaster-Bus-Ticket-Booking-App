import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/constants/app_config.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: "Privacy Policy", showLeading: true,),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Effecive Date: 10 February 2025",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),

              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(text: "Welcome to ShuttleMaster. We value your privacy and are committed to protecting your personal information. This Privacy Policy outlines how we collect, use, and safeguard your data when you use our app.\n\n"),

                    _boldText("1. Information We Collect\n"),
                    TextSpan(text: "\t\t• Usage Data: We collect data on how you interact with the app, including your login history, bus schedules viewed, payment transactions, and any other activities within the app.\n"),
                    TextSpan(text: "\t\t• Device Information: We may collect information about the device you use to access our app, including the device model, operating system, and unique device identifiers.\n\n"),

                    _boldText("2. How We Use Your Information\n"),
                    TextSpan(text: "\t\t• To Provide Services: We use your information to manage and deliver our services, including bus schedule updates, OTP verification, and payment processing.\n"),
                    TextSpan(text: "\t\t• To Improve Our App: We analyze usage data to enhance the functionality, performance, and user experience of the app.\n"),
                    TextSpan(text: "\t\t• Communication: We may use your contact information to send you important updates, notifications, and promotional messages.\n\n"),

                    _boldText("3. Sharing Your Information\n"),
                    TextSpan(text: "\t\t• Third-Party Services: We may share your information with trusted third-party service providers to facilitate app functionalities, such as payment processing and OTP verification. These providers are obligated to protect your data.\n"),
                    TextSpan(text: "\t\t• Legal Requirements: We may disclose your information if required by law or in response to valid legal processes.\n\n"),

                    _boldText("4. Data Security\n"),
                    TextSpan(text: "We implement robust security measures to protect your personal information from unauthorized access, alteration, or disclosure. However, no method of data transmission over the internet is 100% secure, and we cannot guarantee absolute security.\n\n"),

                    _boldText("5. Changes to This Privacy Policy\n"),
                    TextSpan(text: "We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated effective date.\n\n"),

                    _boldText("6. Contact Us\n"),
                    TextSpan(text: "If you have any questions or concerns about this Privacy Policy, please contact us at abc@gmail.com",),
                  ],
                ),
              ),
              SizedBox(height: 30),

              Text(
                AppConfig.appTrademark,
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _boldText(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }
}