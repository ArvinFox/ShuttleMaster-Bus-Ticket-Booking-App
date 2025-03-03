import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new user
  Future<void> createUser(String id, String role) async {
    try {
      String collectionName = role == AppConfig.passengerRole
        ? AppConfig.passengersCollection
        : AppConfig.driversCollection;

      // TODO: Retrieve actual data from NSBM's database

      // Using sample data for testing
      UserModel newUser = (role == AppConfig.passengerRole)
        ? PassengerModel(
            userId: id,
            name: "Test Passenger",
            phone: "+94712345678",
            email: "test.passenger@example.com",
            walletBalance: 0.0,
            registeredAt: DateTime.now(),
          )
        : DriverModel(
            userId: id,
            name: "Test Driver",
            phone: "+94787654321",
            busNo: "NA 1090",
            route: "Test Route 1 - Test Route 2",
            totalIncome: 0.0,
            capacity: 50,
            registeredAt: DateTime.now(),  
          );
      
      await _db.collection(collectionName).doc(id).set(newUser.toFirestore());

    } catch (e) {
      throw Exception("Failed to create user: $e");
    }
  }
  
  // Get a user by ID
  Future<UserModel?> getUserById(String userId, String role) async {
    try {
      String collectionName = role == AppConfig.passengerRole
        ? AppConfig.passengersCollection
        : AppConfig.driversCollection;

      DocumentSnapshot userDoc = await _db.collection(collectionName).doc(userId).get();
      if (!userDoc.exists) return null;

      return (role == AppConfig.passengerRole)
        ? PassengerModel.fromFirestore(userDoc)
        : DriverModel.fromFirestore(userDoc);
     
    } catch (e) {
      throw Exception("Failed to fetch user: $e");
    }
  }
}