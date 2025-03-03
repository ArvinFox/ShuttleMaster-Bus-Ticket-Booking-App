import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shuttlemaster/constants/app_config.dart';

class UserModel {
  final String userId;  // NSBM ID (for passengers) or NIC (for drivers)
  final String name;
  final String phone;
  final String role;
  final DateTime registeredAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.phone,
    required this.role,
    required this.registeredAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    if (data['role'] == AppConfig.passengerRole) {
      return PassengerModel.fromFirestore(doc);
    } else {
      return DriverModel.fromFirestore(doc);
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "phone": phone,
      "role": role,
      "registered_at": registeredAt,
    };
  }
}

class PassengerModel extends UserModel {
  final String email;
  final double walletBalance;

  PassengerModel({
    required super.userId, 
    required super.name, 
    required super.phone, 
    required super.registeredAt,
    required this.email,
    required this.walletBalance,
  }) : super(
        role: AppConfig.passengerRole,
      );

  factory PassengerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return PassengerModel(
      userId: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      registeredAt: (data['registered_at'] as Timestamp).toDate(),
      email: data['email'] ?? '',
      walletBalance: (data['wallet_balance'] ?? 0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return super.toFirestore()
      ..addAll({
        "email": email,
        "wallet_balance": walletBalance,
      });
  }
}

class DriverModel extends UserModel {
  final String busNo;
  final String route;
  final int capacity;
  final double totalIncome;

  DriverModel({
    required super.userId, 
    required super.name, 
    required super.phone, 
    required super.registeredAt,
    required this.busNo,
    required this.route,
    required this.capacity,
    required this.totalIncome,
  }) : super(
        role: AppConfig.driverRole,
      );

  factory DriverModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return DriverModel(
      userId: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      registeredAt: (data['registered_at'] as Timestamp).toDate(),
      busNo: data['bus_no'] ?? '',
      route: data['route'] ?? '',
      capacity: data['capacity'] ?? 0,
      totalIncome: (data['total_income'] ?? 0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    return super.toFirestore()
      ..addAll({
        "bus_no": busNo,
        "route": route,
        "capacity": capacity,
        "total_income": totalIncome,
      });
  }
}