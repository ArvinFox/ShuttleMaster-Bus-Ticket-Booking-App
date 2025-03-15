import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttlemaster/components/custom_header.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/user_model.dart';
import 'package:shuttlemaster/providers/user_provider.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _handleAutoLogin();
    });
  }

  Future<void> _handleAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    bool? hasVisitedHome = prefs.getBool(AppConfig.hasVisitedHomeKey);
    if (hasVisitedHome == null) {
      await prefs.setBool(AppConfig.hasVisitedHomeKey, true);
    }
    
    bool? staySignedIn = prefs.getBool(AppConfig.staySignedInKey);
    String? userId = prefs.getString(AppConfig.userIdKey);
    String? userRole = prefs.getString(AppConfig.userRoleKey);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (staySignedIn == true && userId != null && userRole != null) {
      if (userProvider.user == null && !userProvider.isLoading) {
        await userProvider.fetchUser(userId, userRole);
      }
    } else {
      await _checkStaySignedInPreference();
    }
  }

  Future<void> _checkStaySignedInPreference() async {
    final prefs = await SharedPreferences.getInstance();
    bool? staySignedIn = prefs.getBool(AppConfig.staySignedInKey);

    if (staySignedIn == null) {
      _showStaySignedInDialog();
    }
  }

  void _showStaySignedInDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Stay Signed In?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            "Would you like to stay signed in on this device for easier access next time?",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(AppConfig.staySignedInKey, false);
                prefs.remove(AppConfig.userIdKey);
                prefs.remove(AppConfig.userRoleKey);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("No", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(AppConfig.staySignedInKey, true);

                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user != null) {
                  await prefs.setString(AppConfig.userIdKey, userProvider.user!.userId);
                  await prefs.setString(AppConfig.userRoleKey, userProvider.user!.role);
                }

                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Yes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          backgroundColor: Colors.white,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: -24),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 35,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final user = userProvider.user;
                  return CustomHeader(
                    role: AppConfig.driverRole,
                    name: user?.name ?? "User",
                    busNo: (user as DriverModel).busNo,
                  );
                },
              ),
              SizedBox(height: 15),
        
              Text('Send Alerts', style: TextStyle(fontSize: 20)),
              Divider(thickness: 2),
              SizedBox(height: 5),
        
              _buildAlertItem("The bus will be leaving soon..."),
              _buildAlertItem("The bus has arrived at your destination!"),
              _buildAlertItem("This is an alert!"),
              _buildAlertItem("Are you coming today?"),           
            ],
          )
        ),
      )
    );
  }

  Container _buildAlertItem(String alert) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin:EdgeInsets.only(top: 10),
      padding: EdgeInsets.only(left: 25),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              // 'The bus should be driven rn...',
              alert, 
              style: TextStyle(fontSize: 20)
            ),
          ),
          // SizedBox(width: 10,)
          Container(
            height: 80,
            width: 80,
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.blue,

            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/icons/send.png",),
            ),     
          ),
        ],
      ),
    );
  }
}