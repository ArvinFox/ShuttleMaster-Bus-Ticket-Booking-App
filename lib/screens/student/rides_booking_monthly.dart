import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/components/rides_info_card.dart';
import 'package:shuttlemaster/models/ride_model.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/services/booking_service.dart';
import 'package:shuttlemaster/services/ride_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class RidesScreenMonthly extends StatefulWidget {
  const RidesScreenMonthly({super.key});

  @override
  RidesScreenState createState() => RidesScreenState();
}

class RidesScreenState extends State<RidesScreenMonthly> {
  String? rideId;
  RideModel? ride;
  String? selectedPayment;
  final bookingService = BookingService();
  final rideService = RideService();
  List<Map<String, dynamic>> stops = [];
  String? selectedStop;
  double currentPrice = 300.00;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

      rideId = args['rideId'];
      if (rideId != null) {
        ride = await rideService.getRideById(rideId!);
        await fetchStops(ride);
      }
    });
  }

  Future<void> fetchStops(RideModel? ride) async {
    try {
      if (ride != null && ride.stops.isNotEmpty) {
        stops = ride.stops;
        if (stops.isNotEmpty) {
          setState(() {
            selectedStop = stops.first['stop'];
            updatePrice();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      Helpers.showMessage(context, 'Failed to load pickup spots: $e');
    }
  }

  void updatePrice() {
    if (selectedStop != null) {
      final selectedStopData = stops.firstWhere((stop) => stop['stop'] == selectedStop);
      setState(() {
        currentPrice = selectedStopData['price'].toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomMainAppbar(title: 'Rides', showLeading: true),
      body: SingleChildScrollView(
        child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text(
                    "Join as a monthly member",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Ride Info Card
                  RideInfoCard(
                    rideId: rideId!,
                    busNo: ride!.busNo,
                    startPoint: ride!.route['pickup']!,
                    endPoint: ride!.route['drop']!,
                    time: DateFormat('h:mm a').format(ride!.departureTime),
                    price: "Rs. ${currentPrice.toStringAsFixed(2)}",
                    seatAvailability: "Yes",
                    showPrice: true,
                  ),

                  SizedBox(height: 25),
                  if (stops.isNotEmpty) ...[
                    Text(
                      "Select Pickup Spot",
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    DropdownButton<String>(
                      value: selectedStop,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStop = newValue;
                          updatePrice();
                        });
                      },
                      items: stops.map<DropdownMenuItem<String>>((stop) {
                        return DropdownMenuItem<String>(
                          value: stop['stop'],
                          child: Text(stop['stop']),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                  ],
                  Text(
                    "Payment Method (Recurring)",
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),

                  // Payment Options
                  _buildPaymentOption("Cash", theme),
                  _buildPaymentOption("Card", theme),
                  _buildPaymentOption("Current Balance", theme),

                  SizedBox(height: 40),

                  // OK Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      onPressed: handleBooking,
                      child: Text("OK",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildPaymentOption(String option, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Radio<String>(
          value: option,
          groupValue: selectedPayment,
          activeColor: theme.colorScheme.primary,
          visualDensity: VisualDensity.standard,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (String? value) {
            setState(() {
              selectedPayment = value;
            });
          },
        ),
        Text(option, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  void handleBooking() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (selectedPayment == null) {
      Helpers.showMessage(context, 'Please select a payment method');
      return;
    }

    String userId = userProvider.user!.userId;
    String name = userProvider.user!.name;
    double amount = currentPrice;

    bool isSuccess = await bookingService.createMonthlyBooking(userId, name, rideId!, amount, selectedPayment!, selectedStop!);
    
    if (isSuccess) {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/student/home');
      });
      Helpers.showMessage(context, 'Membership successful');
    } else {
      if (selectedPayment == 'Current Balance') {
        Helpers.showMessage(context, 'Insufficient funds');
      } else {
        Helpers.showMessage(context, 'Membership process failed! Please try again');
      }
    }
  }
}
