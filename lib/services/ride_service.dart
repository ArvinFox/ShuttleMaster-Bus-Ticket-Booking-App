import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/ride_model.dart';

class RideService{
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<RideModel>> fetchDriverRideDetails(String driverId) async{
    try{
      String collectionName = AppConfig.ridesCollection;
      QuerySnapshot ridesDoc = await _db.collection(collectionName).where('driver_id',isEqualTo: driverId).where('status',isEqualTo: 'Completed').orderBy('departure_time',descending: true).get();
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
}