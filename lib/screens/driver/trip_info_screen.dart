import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/models/booking_model.dart';
import 'package:shuttlemaster/models/ride_model.dart';
import 'package:shuttlemaster/services/booking_service.dart';
import 'package:shuttlemaster/services/ride_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class TripInfoScreen extends StatefulWidget {
  final String driverId;
  final String? rideId;

  const TripInfoScreen({
    super.key,
    required this.driverId,
    this.rideId,
  });

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
  List<Map<String, dynamic>>? stops;
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
      if (widget.rideId != null && widget.rideId!.isNotEmpty) {
        ride = await _rideService.getRideById(widget.rideId!);
      } else {
        final now = DateTime.now();
        List<RideModel> driverRides = await _rideService.getDriverRides(widget.driverId);
        driverRides.sort((a, b) => a.departureTime.compareTo(b.departureTime));

        ride = driverRides.firstWhere(
          (r) => r.departureTime.isAfter(now),
          orElse: () => driverRides.first
        );
      }

      if (ride != null) {
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

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        Divider(color: theme.dividerColor),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSectionContent(String content, ThemeData theme) {
    return Text(
      content,
      style: theme.textTheme.bodyMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'LKR ');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    _buildSectionHeader("Route Information", theme),
                    _buildSectionContent("Route: $routeName", theme),
                    _buildSectionContent("Start: $startLocation", theme),
                    _buildSectionContent("End: $endLocation", theme),
                    _buildSectionContent("Stops: ${stops?.map((stopMap) => stopMap['stop']).join(', ')}", theme),

                    SizedBox(height: 16),
                    _buildSectionHeader("Trip Timing", theme),
                    _buildSectionContent("Departure: $departureTime", theme),
                    _buildSectionContent("Arrival (Est.): $estimatedArrivalTime", theme),

                    SizedBox(height: 16),
                    _buildSectionHeader("Seat Information", theme),
                    _buildSectionContent("Reserved Seats: $reservedSeats", theme),
                    _buildSectionContent("Available Seats: $availableSeats", theme),

                    SizedBox(height: 16),
                    _buildSectionHeader("Financial Information", theme),
                    _buildSectionContent("Total Fare: ${currencyFormat.format(totalExpectedFare)}", theme),
                    _buildSectionContent("Collected Fare: ${currencyFormat.format(collectedFare)}", theme),
                    _buildSectionContent("Outstanding Fare: ${currencyFormat.format(outstandingFare)}", theme),

                    SizedBox(height: 16),
                    _buildSectionHeader("Passengers", theme),
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
                                      Text(passenger?['name'], style: theme.textTheme.bodyMedium),
                                      Text(
                                        "Pickup: ${passenger?['pickup']}",
                                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
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
                      : _buildSectionContent("No passengers", theme),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}