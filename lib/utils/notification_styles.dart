import 'package:flutter/material.dart';

enum NotificationType { success, fail, alert, general }

class NotificationStyles {  
  
  static NotificationType getNotificationType(String type) {
    switch (type) {
      case "booking_cancellation":
        return NotificationType.fail;
      case "payment_due":
        return NotificationType.alert;
      case "payment_received":
        return NotificationType.success;
      default:
        return NotificationType.general;
    }
  }

  static IconData getNotificationIcon(NotificationType notificationType) {
    switch (notificationType) {
      case NotificationType.success:
        return Icons.verified;
      case NotificationType.fail:
        return Icons.block;
      case NotificationType.alert:
        return Icons.warning;
      case NotificationType.general:
        return Icons.notifications;
    }
  }  

  static Color getNotificationItemColor(BuildContext context, NotificationType notificationType) {
    final theme = Theme.of(context);

    switch (notificationType) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.fail:
        return Colors.red;
      case NotificationType.alert:
        return Colors.redAccent;
      case NotificationType.general:
        return theme.textTheme.bodyLarge?.color ?? Colors.black;
    }
  }
}