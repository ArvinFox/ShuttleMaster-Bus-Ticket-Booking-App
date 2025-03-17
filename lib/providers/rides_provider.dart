import 'package:flutter/material.dart';
import 'package:shuttlemaster/models/ride_model.dart';
import 'package:shuttlemaster/services/ride_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class RidesProvider extends ChangeNotifier {
  final RideService _rideService = RideService();
  List<RideModel> _rides = [];
  bool _isLoading = false;

  List<RideModel> get rides => _rides;
  bool get isLoading => _isLoading;

  Future<void> fetchRideHistory(String driverId) async{
    _isLoading = true;
    notifyListeners();

    try{
      _rides = await _rideService.fetchDriverRideDetails(driverId);
    }catch (e){
      Helpers.debugPrintWithBorder("Error fetching rides: $e");
    }
    
    _isLoading = false;
    notifyListeners();
  }
}