class AppConfig {
  
  // User Roles
  static const String passengerRole = "passenger";
  static const String driverRole = "driver";

  // OTP Verification Methods
  static const String otpPhone = "phone";
  static const String otpEmail = "email";

  // Invalid ID
  static const String invalidId = "unknown";

  // Shared Preferences Keys
  static const String staySignedInKey = "staySignedIn";
  static const String userIdKey = "userId";
  static const String userRoleKey = "role";

  // Firestore Collections
  static const String passengersCollection = "passengers";
  static const String driversCollection = "drivers";
  static const String ridesCollection = "rides";
  static const String bookingsCollection = "bookings";
  static const String paymentsCollection = "payments";
  static const String notificationsCollection = "notifications";

  // App Trademark
  static const String appTrademark = "©2025 ShuttleMaster All right reserved. Developed by Group 10 (Batch 12 UOP-NSBM)";
}