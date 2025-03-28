import 'package:flutter/material.dart';
import 'package:shuttlemaster/models/booking_model.dart';
import 'package:shuttlemaster/services/booking_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class BookingProvider extends ChangeNotifier{
  final BookingService _bookingService = BookingService();
  List<SingleRideBooking> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get booking => _bookings;
  bool get isLoading => _isLoading;

  Future<void> fetchRideHistory(String userId) async{
    _isLoading = true;
    notifyListeners();

    try{
      List<BookingModel> allBookings = await _bookingService.fetchRideDetails(userId);
      _bookings = allBookings.whereType<SingleRideBooking>().toList();
    }catch (e){
      Helpers.debugPrintWithBorder("Error fetching bookings: $e");
    }
    
    _isLoading = false;
    notifyListeners();
  }
}