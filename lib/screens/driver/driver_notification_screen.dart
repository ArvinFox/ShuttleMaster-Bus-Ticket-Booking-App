import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/models/notification_model.dart';
import 'package:shuttlemaster/providers/notification_provider.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/utils/notification_styles.dart';

class DriverNotificationScreen extends StatefulWidget {
  const DriverNotificationScreen({super.key});

  @override
  State<DriverNotificationScreen> createState() => _DriverNotificationScreenState();
}

class _DriverNotificationScreenState extends State<DriverNotificationScreen> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: "Notifications", showLeading: false),
      body: SingleChildScrollView(
        child: Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            if (notificationProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            final currentNotifications = notificationProvider.notifications;
            if (currentNotifications.isEmpty) {
              return Center(
                child: Text(
                  "No new notifications",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: currentNotifications.length,
              itemBuilder: (context, index) {
                final notification = currentNotifications[index];
                
                return _buildNotificationCard(notification);
              },
            );
          },
        ),
      ),
    );
  }

  GestureDetector _buildNotificationCard(NotificationModel notification) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          Provider.of<NotificationProvider>(context, listen: false)
            .markAsRead(notification.notificationId);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.fromLTRB(8, 12, 8, 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: notification.isRead 
            ? Border()
            : Border.all(color: Colors.black, width: 1.5),
          boxShadow: notification.isRead ? [] : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  Icon(Icons.alarm, size: 12,),
                  SizedBox(width: 2),
                  Text(
                    DateFormat('hh:mm a').format(notification.date), style: TextStyle(fontSize: 12),
                  ),
              ],
            ),
            SizedBox(height: 5),
      
            Row(
              children: [
                Icon(
                  NotificationStyles.getNotificationIcon(NotificationStyles.getNotificationType(notification.type)), 
                  size: 20, 
                  color: NotificationStyles.getNotificationItemColor(NotificationStyles.getNotificationType(notification.type)),
                ),
                SizedBox(width: 2),
                Text(
                  notification.title, 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: NotificationStyles.getNotificationItemColor(NotificationStyles.getNotificationType(notification.type)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
      
            // Text(notification.message),
            Text("This is to inform you that the above booking has been canceled."),
            SizedBox(height: 8),
            Text("Trip Details"),
            Text("\t• Pickup Location: NSBM"),
            Text("\t• Drop-off Location: Mathara"),
          ],
        ),
      ),
    );
  }
}
