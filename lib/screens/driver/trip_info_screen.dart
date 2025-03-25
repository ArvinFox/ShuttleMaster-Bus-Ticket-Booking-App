import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';

class TripInfoScreen extends StatefulWidget {
  const TripInfoScreen({super.key});

  @override
  State<TripInfoScreen> createState() => _TripInfoScreenState();
}

class _TripInfoScreenState extends State<TripInfoScreen> {
  String routeName = "Kadawatha - NSBM";
  String startLocation = "Kadawatha";
  String endLocation = "NSBM";
  List<String> stops = ["Stop 1", "Stop 2", "Stop 3", "Stop 4"];
  String departureTime = "07:00 AM";
  String estimatedArrivalTime = "08:30 AM";
  int reservedSeats = 50;
  int availableSeats = 20;
  double totalExpectedFare = 5000.0;
  double collectedFare = 2000.0;
  List<Map<String, dynamic>> passengers = [
    {"name": "Passenger 1", "is_paid": true, "pickup": "Stop 2"},
    {"name": "Passenger 2", "is_paid": false, "pickup": "Stop 3"},
  ];

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
    double outstandingFare = totalExpectedFare - collectedFare;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: "Trip Information"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Route Information"),
                _buildSectionContent("Route: $routeName"),
                _buildSectionContent("Start: $startLocation"),
                _buildSectionContent("End: $endLocation"),
                _buildSectionContent("Stops: ${stops.join(', ')}"),

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
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: passengers.length,
                  itemBuilder: (context, index) {
                    final passenger = passengers[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(passenger['name'], style: TextStyle(fontSize: 16)),
                              Text(
                                "Pickup: ${passenger['pickup']}",
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            width: 100,
                            decoration: BoxDecoration(
                              color: passenger['is_paid'] ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              passenger['is_paid'] ? "PAID" : "NOT PAID",
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}