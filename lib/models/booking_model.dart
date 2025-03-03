import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String rideId;
  final String userId;
  final String status;
  final double amount;
  final DateTime bookedAt;
  final bool isPaid;

  BookingModel({
    required this.bookingId, 
    required this.rideId, 
    required this.userId, 
    required this.status, 
    required this.amount, 
    required this.bookedAt, 
    this.isPaid = false,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return BookingModel(
      bookingId: doc.id,
      rideId: data['ride_id'] ?? '',
      userId: data['user_id'] ?? '',
      status: data['status'] ?? 'confirmed',
      amount: (data['amount'] ?? 0.0).toDouble(),
      bookedAt: (data['booked_at'] as Timestamp).toDate(),
      isPaid: data['is_paid'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "ride_id": rideId,
      "user_id": userId,
      "status": status,
      "amount": amount,
      "booked_at": Timestamp.fromDate(bookedAt),
      "is_paid": isPaid,
    };
  }
}