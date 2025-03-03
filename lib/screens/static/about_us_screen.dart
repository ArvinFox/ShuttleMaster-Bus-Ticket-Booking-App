import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/constants/app_config.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: "About Us"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset("assets/images/common-image.png", height: 200),
              ),
              SizedBox(height: 20),

              Text(
                "Welcome to ShuttleMaster, your trusted companion for seamless campus transportation. Our mission is to enhance the convenience and efficiency of student travel by providing real-time bus schedules and a hassle-free payment system.\n\n"

                "With ShuttleMaster, effortlessly track bus timings, receive timely notifications, and make secure payments with just a few taps. Our app is designed to ensure a smooth and reliable transit experience, helping you navigate the campus with ease and confidence.\n\n"

                "Join us in revolutionizing campus travel, making it more accessible, efficient, and enjoyable. Let\'s make your daily commute a breeze, allowing you to focus on what truly matters-your academic journey and campus life.",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 20),
              Divider(),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/privacy-policy");
                },
                child: Text("Privacy Policy"),
              ),

              Divider(),
              SizedBox(height: 8),

              Text(
                "For More Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset("assets/icons/facebook.png", height: 30),
                    onPressed: () {},
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Image.asset("assets/icons/google.png", height: 30),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 20),

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
}