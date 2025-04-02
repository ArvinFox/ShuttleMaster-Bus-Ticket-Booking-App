import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttlemaster/components/custom_header.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/notification_model.dart';
import 'package:shuttlemaster/models/ride_model.dart';
import 'package:shuttlemaster/models/user_model.dart';
import 'package:shuttlemaster/providers/notification_provider.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/services/ride_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final RideService _rideService = RideService();

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
          title: Text("Stay Signed In?"),
          content: Text("Would you like to stay signed in on this device for easier access next time?"),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(AppConfig.staySignedInKey, false);
                prefs.remove(AppConfig.userIdKey);
                prefs.remove(AppConfig.userRoleKey);
                Navigator.of(context).pop();
              },
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
              child: Text("Yes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        );
      }
    );
  }

  void _sendAlert(String message) async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    try {
      String rideId = "5";
      RideModel? ride = await _rideService.getRideById(rideId);

      if (ride == null) {
        Helpers.showMessage(context, "Unable to load ride details.");
      } else {
        for (Map<String, dynamic> passengerInfo in ride.passengers) {
          String notificationId = FirebaseFirestore.instance.collection(AppConfig.notificationsCollection).doc().id;

          NotificationModel notification = createNotificationFromMessage(message, passengerInfo['passenger_id'], notificationId, rideId);

          await notificationProvider.createNotification(notification); 
        }
        Helpers.showMessage(context, "Alert sent successfully!");
      }

    } catch (e) {
      Helpers.showMessage(context, "Failed to send alert: $e");
    }
  }

  NotificationModel createNotificationFromMessage(String driverMessage, String userId, String notificationId, String rideId) {
    String type = "";
    String title = "";
    String message = "";

    if (driverMessage == "The bus will be leaving soon...") {
      type = "reminder";
      title = "Departure Reminder";
      message = "The bus will be leaving soon. Please be ready at the designated stop.";
    } else if (driverMessage == "The bus has arrived at your destination!") {
      type = "reminder";
      title = "Arrival Notice";
      message = "The bus has arrived at your destination. Please disembark safely.";
    } else if (driverMessage == "Are you coming today?") {
      type = "confirm_attendance";
      title = "Attendance Check";
      message = "Are you coming today? Please confirm your attendance";
    } else {
      type = "reminder";
      title = "Reminder";
      message = driverMessage;
    }

    return NotificationModel(
      notificationId: notificationId,
      userId: userId,
      rideId: rideId,
      type: type,
      title: title,
      message: message,
      date: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(toolbarHeight: -24, backgroundColor: theme.colorScheme.primary),
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
        
              Text('Send Alerts', style: theme.textTheme.bodyLarge),
              Divider(thickness: 2, color: theme.dividerColor),
              SizedBox(height: 5),
        
              _buildAlertItem("The bus will be leaving soon...", theme),
              _buildAlertItem("The bus has arrived at your destination!", theme),
              _buildAlertItem("This is an alert!", theme),
              _buildAlertItem("Are you coming today?", theme),           
            ],
          )
        ),
      )
    );
  }

  Container _buildAlertItem(String alert, ThemeData theme) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin:EdgeInsets.only(top: 10),
      padding: EdgeInsets.only(left: 25),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.onSurface, width: 1.5),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              // 'The bus should be driven rn...',
              alert, 
              style: theme.textTheme.bodyLarge
            ),
          ),
          // SizedBox(width: 10,)
          GestureDetector(
            onTap: () => _sendAlert(alert),
            child: Container(
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
          ),
        ],
      ),
    );
  }
}