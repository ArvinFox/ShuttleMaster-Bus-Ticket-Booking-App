import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String rideId;
  final String driverId;
  final String busNo;
  final Map<String, String> route;
  final List<String> stops;
  final DateTime departureTime;
  DateTime? completedTime;
  final int duration; // in minutes
  final int totalSeats;
  int availableSeats;
  int reservedSeats;
  final List<Map<String, dynamic>> passengers;
  final String status;
  double totalIncome;
  final double distance;


  RideModel({
    required this.rideId, 
    required this.driverId, 
    required this.busNo, 
    required this.route, 
    required this.stops,
    required this.departureTime, 
    this.completedTime, 
    required this.duration,
    required this.totalSeats, 
    required this.availableSeats, 
    required this.reservedSeats,
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
      stops: List<String>.from(data['stops'] ?? []),
      departureTime: (data['departure_time'] as Timestamp).toDate(),
      completedTime: data['completed_time'] != null
        ? (data['completed_time'] as Timestamp).toDate()
        : DateTime.now(),
      duration: data['duration'] ?? 60,
      totalSeats: data['total_seats'] ?? 0,
      availableSeats: data['available_seats'] ?? 0,
      reservedSeats: data['reserved_seats'] ?? 0,
      passengers: List<Map<String, dynamic>>.from(data['passengers']?.map((item) => item as Map<String, dynamic>) ?? []),
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
      "stops": stops,
      "departure_time": Timestamp.fromDate(departureTime),
      "completed_time": Timestamp.fromDate(departureTime),
      "duration": duration,
      "total_seats": totalSeats,
      "available_seats": availableSeats,
      "reserved_seats": reservedSeats,
      "passengers": passengers.map((item) => item).toList(),
      "status": status,
      "total_income": totalIncome,
      "distance": distance,
    };
  }
}