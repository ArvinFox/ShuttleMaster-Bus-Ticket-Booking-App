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

    if (data.containsKey('start_date')) {
      return MonthlyBooking.fromFirestore(doc);
    } else {
      return SingleRideBooking.fromFirestore(doc);
    }
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

class SingleRideBooking extends BookingModel {
  final String tripType;
  final DateTime bookingDate;

  SingleRideBooking(
      {required super.bookingId,
      required super.rideId,
      required super.userId,
      required super.status,
      required super.amount,
      required super.bookedAt,
      super.isPaid,
      required this.tripType,
      required this.bookingDate});

  factory SingleRideBooking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return SingleRideBooking(
      bookingId: doc.id,
      rideId: data['ride_id'] ?? '',
      userId: data['user_id'] ?? '',
      status: data['status'] ?? 'confirmed',
      amount: (data['amount'] ?? 0.0).toDouble(),
      bookedAt: (data['booked_at'] as Timestamp).toDate(),
      isPaid: data['is_paid'] ?? false,
      tripType: data['trip_type'] ?? 'One-Way',
      bookingDate: (data['booking_date'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return super.toFirestore()
      ..addAll({'trip_type': tripType, 'booking_date': bookingDate});
  }
}

class MonthlyBooking extends BookingModel {
  final DateTime startDate;
  final DateTime endDate;

  MonthlyBooking(
      {required super.bookingId,
      required super.rideId,
      required super.userId,
      required super.status,
      required super.amount,
      required super.bookedAt,
      super.isPaid,
      required this.startDate,
      required this.endDate});

  factory MonthlyBooking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return MonthlyBooking(
      bookingId: doc.id,
      rideId: data['ride_id'] ?? '',
      userId: data['user_id'] ?? '',
      status: data['status'] ?? 'confirmed',
      amount: (data['amount'] ?? 0.0).toDouble(),
      bookedAt: (data['booked_at'] as Timestamp).toDate(),
      isPaid: data['is_paid'] ?? false,
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp).toDate(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return super.toFirestore()
      ..addAll({'start_date': startDate, 'end_date': endDate});
  }
}
