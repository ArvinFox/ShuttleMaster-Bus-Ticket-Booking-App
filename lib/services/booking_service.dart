import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //create single booking
  Future<bool> createSingleBooking(
      String rideId,
      String userId,
      String username,
      String paymentMethod,
      String tripType,
      DateTime bookingDate,
      double amount,
      String pickup) async {
    try {
      bool isPaid = paymentMethod == "Card";

      if (paymentMethod == 'Current Balance') {
        DocumentSnapshot userDoc =  await _db.collection('passengers').doc(userId).get();
        if (!userDoc.exists) throw Exception('User not found');

        double walletBalance = (userDoc['wallet_balance'] as num?)?.toDouble() ?? 0.0;
        if (walletBalance < amount) return false;

        await _db
            .collection('passengers')
            .doc(userId)
            .update({'wallet_balance': walletBalance - amount});
          isPaid = true;
      }

      String bookingId = _db.collection('bookings').doc('single').collection('rides').doc().id;
      String status = bookingDate.isAfter(DateTime.now()) ? 'Upcoming' : '';

      BookingModel booking = SingleRideBooking(
        bookingId: bookingId,
        rideId: rideId,
        userId: userId,
        status: status,
        amount: amount,
        bookedAt: DateTime.now(),
        isPaid: isPaid,
        tripType: tripType,
        bookingDate: bookingDate, 
        paymentMethod: paymentMethod,
        cancelledDate: null,
        pickup: pickup,
      );

      await _db
        .collection('bookings')
        .doc('single')
        .collection('rides')
        .doc(bookingId)
        .set(booking.toFirestore());

      await _db.collection('rides').doc(rideId).update({
        'available_seats': FieldValue.increment(-1),
        'passengers': FieldValue.arrayUnion([
          {
            "attendance_status": "Coming",
            "is_paid": isPaid,
            "name": username,
            "passenger_id": userId,
            "pickup": pickup,
          }
        ])
      });
      return true;
    } catch (e) {
      throw Exception('Fail to create single booking: $e');
    }
  }

  //create monthly booking
  Future<bool> createMonthlyBooking(
      String userId, String username, String rideId, double amount, String paymentMethod, String pickup) async {
    try {
      bool isPaid = paymentMethod == "Card";

      if (paymentMethod == 'Current Balance') {
        DocumentSnapshot userDoc =  await _db.collection('passengers').doc(userId).get();
        if (!userDoc.exists) throw Exception('User not found');

        double walletBalance = (userDoc['wallet_balance'] as num?)?.toDouble() ?? 0.0;
        if (walletBalance < amount) return false;

        await _db
          .collection('passengers')
          .doc(userId)
          .update({'wallet_balance': walletBalance - amount});
        isPaid = true;
      }

      String bookingId = _db
        .collection('bookings')
        .doc('monthly')
        .collection('rides')
        .doc()
        .id;
      

      DateTime now = DateTime.now();
      DateTime startDate = DateTime(now.year, now.month, 1);
      DateTime endDate =  DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));

      BookingModel booking = MonthlyBooking(
        bookingId: bookingId,
        rideId: rideId,
        userId: userId,
        status: 'Confirmed',
        amount: amount,
        bookedAt: DateTime.now(),
        isPaid: false,
        startDate: startDate,
        endDate: endDate, 
        paymentMethod: paymentMethod,
        pickup: pickup,
      );

      await _db
        .collection('bookings')
        .doc('monthly')
        .collection('rides')
        .doc(bookingId)
        .set(booking.toFirestore());

      await _db.collection('rides').doc(rideId).update({
        'available_seats': FieldValue.increment(-1),
        'passengers': FieldValue.arrayUnion([
          {
            "attendance_status": "Coming",
            "is_paid": isPaid,
            "name": username,
            "passenger_id": userId,
            "pickup": pickup,
          }
        ])
      });
      return true;
    } catch (e) {
      throw Exception('Fail to create monthly booking: $e');
    }
  }

  //fetch Booking details
  Future<List<BookingModel>> fetchRideDetails(String userId) async{
    try{
      QuerySnapshot bookingsDoc = await _db.collection(AppConfig.bookingsCollection).doc("single").collection("rides").where('user_id',isEqualTo: userId).orderBy('booking_date',descending: true).get();

      return bookingsDoc.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();

    }catch (e){
      throw Exception("Failed to fetch details: $e");
    }
  }

  // Fetch the bookings of a particular ride
  Future<List<BookingModel>> getRideBookings(String rideId) async {
    QuerySnapshot bookingSnapshot = await _db.collection(AppConfig.bookingsCollection).where('ride_id', isEqualTo: rideId).get();

    return bookingSnapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      DocumentSnapshot bookingDoc = await _db.collection(AppConfig.bookingsCollection).doc("single").collection("rides").doc(bookingId).get();
      if (!bookingDoc.exists) return null;

      return BookingModel.fromFirestore(bookingDoc);

    } catch (e) {
      throw Exception("Failed to fetch booking: $e");
    }
  }

  //update status as "Cancelled" when cancell booking
  Future<void> updateState(String bookingId) async{
    try{
      await _db.collection(AppConfig.bookingsCollection).doc("single").collection("rides").doc(bookingId).update({'status': 'Cancelled', 'cancelled_date': DateTime.now()});
    }catch (e){
      throw Exception("Failed to fetch booking : $e");
    }
  }

  //update payment status after payed using total payable screen
  Future<void> updatePaymentState(String bookingId) async{
    try{
      await _db.collection(AppConfig.bookingsCollection).doc("single").collection("rides").doc(bookingId).update({'is_paid': true, 'payment_method': 'Card'});
    }catch (e){
      throw Exception("Failed to fetch booking : $e");
    }
  }
}
