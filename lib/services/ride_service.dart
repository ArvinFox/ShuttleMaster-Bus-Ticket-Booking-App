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
}