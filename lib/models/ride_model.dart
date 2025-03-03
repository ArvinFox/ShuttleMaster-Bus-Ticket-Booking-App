import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String rideId;
  final String driverId;
  final Map<String, String> route;
  final DateTime departureTime;
  final int totalSeats;
  final int availableSeats;
  final List<String> passengers;
  final String status;

  RideModel({
    required this.rideId, 
    required this.driverId, 
    required this.route, 
    required this.departureTime, 
    required this.totalSeats, 
    required this.availableSeats, 
    required this.passengers, 
    required this.status,
  });

  factory RideModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return RideModel(
      rideId: doc.id,
      driverId: data['driver_id'] ?? '',
      route: {
        "pickup": data['route']['pickup'] ?? '',
        "drop": data['route']['drop'] ?? '',
      },
      departureTime: (data['departure_time'] as Timestamp).toDate(),
      totalSeats: data['total_seats'] ?? 0,
      availableSeats: data['available_seats'] ?? 0,
      passengers: List<String>.from(data['passengers'] ?? []),
      status: data['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "driver_id": driverId,
      "route": {
        "pickup": route['pickup'] ?? '',
        "drop": route['drop'] ?? '',
      },
      "departure_time": Timestamp.fromDate(departureTime),
      "total_seats": totalSeats,
      "available_seats": availableSeats,
      "passengers": passengers,
      "status": status,
    };
  }
}