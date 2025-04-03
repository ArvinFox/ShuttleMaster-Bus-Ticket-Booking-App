import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/models/notification_model.dart';
import 'package:shuttlemaster/providers/notification_provider.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/services/ride_service.dart';
import 'package:shuttlemaster/utils/notification_styles.dart';

class StudentNotificationScreen extends StatefulWidget {
  const StudentNotificationScreen({super.key});

  @override
  State<StudentNotificationScreen> createState() => _StudentNotificationScreenState();
}

class _StudentNotificationScreenState extends State<StudentNotificationScreen> {
  bool _attendanceConfirmed = false;
  final RideService _rideService = RideService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

      if (notificationProvider.notifications.isEmpty) {
        await notificationProvider.fetchNotifications(userProvider.user!.userId);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomMainAppbar(title: "Notifications", showLeading: false),
      body: SingleChildScrollView(
        child: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            if (notificationProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                final notificationType = NotificationStyles.getNotificationType(notification.type);
                final iconColor = NotificationStyles.getNotificationItemColor(context, notificationType);

                return Column(
                  children: [
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.fromLTRB(8, 12, 8, 10),
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.alarm, size: 12,),
                                    SizedBox(width: 2),
                                    Text(DateFormat('hh:mm a').format(notification.date), style: TextStyle(fontSize: 12, color: theme.textTheme.bodyLarge?.color)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      NotificationStyles.getNotificationIcon(NotificationStyles.getNotificationType(notification.type)), 
                                      size: 20, 
                                      color: iconColor,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      notification.title, 
                                      style: TextStyle(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.bold, 
                                        color: iconColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(18, 3, 8, 8),
                                  child: Text(notification.message, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 8),

                          _buildAttendaceConfirmationButtons(notification, theme),                     
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttendaceConfirmationButtons(NotificationModel notification, ThemeData theme) {
    if (notification.type == "confirm_attendace") {
      return _attendanceConfirmed
        ? Text("Attendance Confirmed!", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))
        : Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      _rideService.updateAttendanceStatus(notification.rideId!, notification.userId, "Coming");
                      setState(() {
                        _attendanceConfirmed = true;
                      });
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: Text("Coming", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
                  ),
                ),
              ),
              SizedBox(width: 8,),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      _rideService.updateAttendanceStatus(notification.rideId!, notification.userId, "Not Coming");
                      setState(() {
                        _attendanceConfirmed = true;
                      });
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: Text("Not Coming", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
                  ),
                ),
              ),
            ],
          );
    } else {
      return SizedBox.shrink();
    }
  }
}