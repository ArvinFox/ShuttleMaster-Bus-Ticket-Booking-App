import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String userId;
  final String type;
  final String message;
  final DateTime date;
  final bool isRead;

  NotificationModel({
    required this.notificationId, 
    required this.userId, 
    required this.type, 
    required this.message, 
    required this.date, 
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      notificationId: doc.id,
      userId: data['user_id'] ?? '',
      type: data['type'] ?? '',
      message: data['message'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isRead: data['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "user_id": userId,
      "type": type,
      "message": message,
      "date": Timestamp.fromDate(date),
      "is_read": isRead,
    };
  }
}