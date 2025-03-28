import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String userId;
  final String? rideId;
  final String type;
  final String title;
  final String message;
  final DateTime date;
  bool isRead;

  NotificationModel({
    required this.notificationId, 
    required this.userId, 
    this.rideId,
    required this.type, 
    required this.title,
    required this.message, 
    required this.date, 
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      notificationId: doc.id,
      userId: data['user_id'] ?? '',
      rideId: data['ride_id'],
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isRead: data['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "user_id": userId,
      "ride_id": rideId,
      "type": type,
      "title": title,
      "message": message,
      "date": Timestamp.fromDate(date),
      "is_read": isRead,
    };
  }
}