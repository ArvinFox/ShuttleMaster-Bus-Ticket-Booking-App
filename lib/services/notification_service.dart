import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a notification
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _db.collection(AppConfig.notificationsCollection).doc(notification.notificationId).set(notification.toFirestore());
    } catch (e) {
      throw Exception("Failed to create notification: $e");
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _db.collection(AppConfig.notificationsCollection).doc(notificationId).update({"is_read": true});
  }

  // Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    QuerySnapshot snapshot = await _db
      .collection(AppConfig.notificationsCollection)
      .where('user_id', isEqualTo: userId)
      .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'is_read': true});
    }
  }

  // Get a notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    DocumentSnapshot doc = await _db.collection(AppConfig.notificationsCollection).doc(notificationId).get();
    if (!doc.exists) return null;

    return NotificationModel.fromFirestore(doc);  
  }

  // Get all unread notifications for a user
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    QuerySnapshot snapshot = await _db
      .collection(AppConfig.notificationsCollection)
      .where('user_id', isEqualTo: userId)
      .where('is_read', isEqualTo: false)
      .get();

    return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
  }
}