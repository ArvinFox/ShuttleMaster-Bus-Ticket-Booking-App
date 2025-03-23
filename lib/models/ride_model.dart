import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String rideId;
  final String driverId;
  final String busNo;
  final Map<String, String> route;
  final DateTime departureTime;
  final DateTime completedTime;
  final int totalSeats;
  final int availableSeats;
  final List<String> passengers;
  final String status;
  final double totalIncome;
  final double distance;


  RideModel({
    required this.rideId, 
    required this.driverId, 
    required this.busNo, 
    required this.route, 
    required this.departureTime, 
    required this.completedTime, 
    required this.totalSeats, 
    required this.availableSeats, 
    required this.passengers, 
    required this.status,
    required this.totalIncome,
    required this.distance,
  });

  factory RideModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return RideModel(
      rideId: doc.id,
      driverId: data['driver_id'] ?? '',
      busNo: data['bus_no'] ?? '',
      route: {
        "pickup": data['route']['pickup'] ?? '',
        "drop": data['route']['drop'] ?? '',
      },
      departureTime: (data['departure_time'] as Timestamp).toDate(),
      completedTime: (data['completed_time'] as Timestamp).toDate(),
      totalSeats: data['total_seats'] ?? 0,
      availableSeats: data['available_seats'] ?? 0,
      passengers: List<String>.from(data['passengers'] ?? []),
      status: data['status'] ?? 'scheduled',
      totalIncome: (data['total_income'] ?? 0).toDouble(),
      distance: (data['distance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "driver_id": driverId,
      "bus_no" : busNo,
      "route": {
        "pickup": route['pickup'] ?? '',
        "drop": route['drop'] ?? '',
      },
      "departure_time": Timestamp.fromDate(departureTime),
      "completed_time": Timestamp.fromDate(departureTime),
      "total_seats": totalSeats,
      "available_seats": availableSeats,
      "passengers": passengers,
      "status": status,
      "total_income": totalIncome,
      "distance": distance,
    };
  }
}