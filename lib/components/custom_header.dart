import 'package:flutter/material.dart';
import 'package:shuttlemaster/constants/app_config.dart';

class CustomHeader extends StatelessWidget {
  final String role;
  final String name;
  final double? accountBalance;
  final String? busNo;

  const CustomHeader({
    super.key, 
    required this.role, 
    required this.name,
    this.accountBalance = 0.0,
    this.busNo = "NA-1090",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: 40,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreetingMessage(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildInfoBox(),
            ],
          ),
        ),
      ],
    );
  }

  Container _buildInfoBox() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            role == AppConfig.driverRole 
              ? 'Kadawatha - NSBM' 
              : 'Current Account Balance:',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          Text(
            role == AppConfig.driverRole 
              ? busNo! 
              : accountBalance!.toString(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12) {
      return "Good Morning!";
    } else if (hour >= 12 && hour < 16) {
      return "Good Afternoon!";
    } else {
      return "Good Evening!";
    }
  }
}
