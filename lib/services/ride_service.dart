import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/ride_model.dart';

class RideService{
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<RideModel>> fetchDriverRideDetails(String driverId) async{
    try{
      QuerySnapshot ridesDoc = await _db.collection(AppConfig.ridesCollection).where('driver_id',isEqualTo: driverId).where('status',isEqualTo: 'Completed').orderBy('departure_time',descending: true).get();
      return ridesDoc.docs.map((doc) => RideModel.fromFirestore(doc)).toList();
    }catch (e){
      throw Exception("Failed to fetch details: $e");
    }
  }

  // Get ride by ID
  Future<RideModel?> getRideById(String rideId) async {
    try {
      DocumentSnapshot rideDoc = await _db.collection(AppConfig.ridesCollection).doc(rideId).get();
      if (!rideDoc.exists) return null;

      return RideModel.fromFirestore(rideDoc);

    } catch (e) {
      throw Exception("Failed to fetch ride: $e");
    }
  }

  // Update passenger attendance status
  Future<void> updateAttendanceStatus(String rideId, String passengerId, String status) async {
    try {
      DocumentReference rideRef = _db.collection(AppConfig.ridesCollection).doc(rideId);

      DocumentSnapshot rideDoc = await rideRef.get();
      if (!rideDoc.exists) throw Exception("Ride not found");

      List<Map<String, dynamic>> passengers = List<Map<String, dynamic>>.from(rideDoc['passengers']);

      for (var passenger in passengers) {
        if (passenger['passenger_id'] == passengerId) {
          passenger['attendance_status'] = status;
          break;
        }
      }

      await rideRef.update({'passengers': passengers});

    } catch (e) {
      throw Exception("Failed to update attendance status: $e");
    }
  }

  //update ride collection when cancelling a booking
  Future<void> updateRidesOnCancellation(String rideId, String passengerId) async {
    try {
      var rideDoc = await _db.collection(AppConfig.ridesCollection).doc(rideId).get();
      if (!rideDoc.exists)  throw Exception("Ride not found");

      RideModel ride = RideModel.fromFirestore(rideDoc);

      ride.availableSeats += 1;
      ride.reservedSeats -= 1;

      ride.passengers.removeWhere((passenger) => passenger['passenger_id'] == passengerId);

      await _db.collection(AppConfig.ridesCollection).doc(rideId).update({
        'available_seats': ride.availableSeats,
        'reserved_seats': ride.reservedSeats,
        'passengers': ride.passengers,
      });
    } catch (e) {
      throw Exception("Failed to update ride: $e");
    }
  }
}