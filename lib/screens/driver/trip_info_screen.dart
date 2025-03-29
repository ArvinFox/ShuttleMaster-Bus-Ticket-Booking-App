import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/models/booking_model.dart';
import 'package:shuttlemaster/models/ride_model.dart';
import 'package:shuttlemaster/services/booking_service.dart';
import 'package:shuttlemaster/services/ride_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class TripInfoScreen extends StatefulWidget {
  const TripInfoScreen({super.key});

  @override
  State<TripInfoScreen> createState() => _TripInfoScreenState();
}

class _TripInfoScreenState extends State<TripInfoScreen> {
  RideModel? ride;
  final _bookingService = BookingService();
  final _rideService = RideService();

  bool _isLoading = true;

  String? routeName;
  String? startLocation;
  String? endLocation;
  List<String>? stops;
  String? departureTime;
  String? estimatedArrivalTime;
  int? reservedSeats;
  int? availableSeats;
  double? totalExpectedFare;
  double? collectedFare;
  double? outstandingFare;
  List<Map<String, dynamic>>? passengers;

  @override
  void initState() {
    super.initState();
    _fetchRideData();
  }

  Future<void> _fetchRideData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      ride = await _rideService.getRideById("5"); // For testing purposes

      if (ride != null) {
        Helpers.debugPrintWithBorder("NOT NULL");
        Helpers.debugPrintWithBorder(ride.toString());

        routeName = "${ride?.route['pickup']} - ${ride?.route['drop']}";
        startLocation = "${ride?.route['pickup']}";
        endLocation = "${ride?.route['drop']}";
        stops = ride!.stops;
        departureTime = DateFormat('hh:mm a').format(ride!.departureTime);
        estimatedArrivalTime = DateFormat('hh:mm a').format(ride!.departureTime.add(Duration(minutes: ride!.duration)));
        reservedSeats = ride!.reservedSeats;
        availableSeats = ride!.availableSeats;
        List<BookingModel> rideBookings = await _bookingService.getRideBookings(ride!.rideId);
        totalExpectedFare = calculateTotalExpectedFare(rideBookings);  
        collectedFare = ride!.totalIncome;
        outstandingFare = totalExpectedFare! - collectedFare!;
        passengers = ride!.passengers;
      } else {
        Helpers.debugPrintWithBorder("NULL");
      }

    } catch (e) {
      Helpers.debugPrintWithBorder("Error fetching ride data: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  double calculateTotalExpectedFare(List<BookingModel> bookings) {
    double totalExpectedFare = 0;
    for (BookingModel booking in bookings) {
      double amount = booking.amount;
      totalExpectedFare += amount;
    }
    return totalExpectedFare;
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Divider(color: Colors.grey[800]),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'LKR ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: "Trip Information", showLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Route Information"),
                    _buildSectionContent("Route: $routeName"),
                    _buildSectionContent("Start: $startLocation"),
                    _buildSectionContent("End: $endLocation"),
                    _buildSectionContent("Stops: ${stops?.join(', ')}"),

                    SizedBox(height: 16),
                    _buildSectionHeader("Trip Timing"),
                    _buildSectionContent("Departure: $departureTime"),
                    _buildSectionContent("Arrival (Est.): $estimatedArrivalTime"),

                    SizedBox(height: 16),
                    _buildSectionHeader("Seat Information"),
                    _buildSectionContent("Reserved Seats: $reservedSeats"),
                    _buildSectionContent("Available Seats: $availableSeats"),

                    SizedBox(height: 16),
                    _buildSectionHeader("Financial Information"),
                    _buildSectionContent("Total Fare: ${currencyFormat.format(totalExpectedFare)}"),
                    _buildSectionContent("Collected Fare: ${currencyFormat.format(collectedFare)}"),
                    _buildSectionContent("Outstanding Fare: ${currencyFormat.format(outstandingFare)}"),

                    SizedBox(height: 16),
                    _buildSectionHeader("Passengers"),
                    passengers != null && passengers!.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: passengers?.length,
                          itemBuilder: (context, index) {
                            final passenger = passengers?[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(passenger?['name'], style: TextStyle(fontSize: 16)),
                                      Text(
                                        "Pickup: ${passenger?['pickup']}",
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: passenger?['is_paid'] ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      passenger?['is_paid'] ? "PAID" : "NOT PAID",
                                      style: TextStyle(
                                        color: Colors.white, 
                                        fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : _buildSectionContent("No passengers"),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}