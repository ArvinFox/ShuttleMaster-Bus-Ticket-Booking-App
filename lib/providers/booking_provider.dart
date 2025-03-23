import 'package:flutter/material.dart';
import 'package:shuttlemaster/models/booking_model.dart';
import 'package:shuttlemaster/services/booking_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class BookingProvider extends ChangeNotifier{
  final BookingService _bookingService = BookingService();
  List<SingleRideBooking> _bookings = [];
  Map<String, String>? _routeData;
  Map<String, String>? _busNo = {};
  bool _isLoading = false;

  List<BookingModel> get booking => _bookings;
  Map<String, String>? get routeData => _routeData;
  Map<String, String>? get busNo => _busNo;
  bool get isLoading => _isLoading;

  Future<void> fetchRideHistory(String userId) async{
    _isLoading = true;
    notifyListeners();

    try{
      List<BookingModel> allBookings = await _bookingService.fetchRideDetails(userId);
      _bookings = allBookings.whereType<SingleRideBooking>().toList();

      print('------------user id => $userId----------------------');

      //fetch route data
      for (var booking in _bookings) {
        Map<String, String>? route = await _bookingService.getPickupAndDropForBooking(booking.bookingId);
        Map<String, String>? busNo = await _bookingService.fetchBusNo(booking.rideId,booking.bookingId);
        if (route != null && busNo != null) {
          _routeData = route; 
          _busNo = busNo;
        }
      }
      print('------------Bus No => $busNo----------------------');
    }catch (e){
      Helpers.debugPrintWithBorder("Error fetching bookings: $e");
    }
    
    _isLoading = false;
    notifyListeners();
  }
}