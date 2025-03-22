import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shuttlemaster/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //create single booking

  Future<bool> createSingleBooking(
      String rideId,
      String userId,
      String paymentMethod,
      String tripType,
      DateTime bookingDate,
      double amount) async {
    try {
      if (paymentMethod == 'Current Balance') {
        DocumentSnapshot userDoc =
            await _db.collection('passengers').doc(userId).get();
        if (!userDoc.exists) throw Exception('User not found');

        double walletBalance =
            (userDoc['wallet_balance'] as num?)?.toDouble() ?? 0.0;
        if (walletBalance < amount) return false;

        await _db
            .collection('passengers')
            .doc(userId)
            .update({'wallet_balance': walletBalance - amount});
      }
      String bookingId =
          _db.collection('bookings').doc('single').collection('rides').doc().id;

      BookingModel booking = SingleRideBooking(
          bookingId: bookingId,
          rideId: rideId,
          userId: userId,
          status: 'Confirmed',
          amount: amount,
          bookedAt: DateTime.now(),
          isPaid: false,
          tripType: tripType,
          bookingDate: bookingDate);

      await _db
          .collection('bookings')
          .doc('single')
          .collection('rides')
          .doc(bookingId)
          .set(booking.toFirestore());

      await _db.collection('rides').doc(rideId).update({
        'available_seats': FieldValue.increment(-1),
        'passengers': FieldValue.arrayUnion([userId])
      });
      return true;
    } catch (e) {
      throw Exception('Fail to create single booking: $e');
    }
  }

  //create monthly booking

  Future<void> createMonthlyBooking(
      String userId, String rideId, double amount) async {
    try {
      String bookingId = _db
          .collection('bookings')
          .doc('monthly')
          .collection('rides')
          .doc()
          .id;

      DateTime now = DateTime.now();
      DateTime startDate = DateTime(now.year, now.month, 1);
      DateTime endDate =
          DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));

      BookingModel booking = MonthlyBooking(
          bookingId: bookingId,
          rideId: rideId,
          userId: userId,
          status: 'Confirmed',
          amount: amount,
          bookedAt: DateTime.now(),
          isPaid: false,
          startDate: startDate,
          endDate: endDate);

      await _db
          .collection('bookings')
          .doc('monthly')
          .collection('rides')
          .doc(bookingId)
          .set(booking.toFirestore());

      await _db.collection('rides').doc(rideId).update({
        'reserved_seats': FieldValue.increment(1),
        'passengers': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      throw Exception('Fail to create monthly booking: $e');
    }
  }
}
