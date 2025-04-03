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

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  String? rideId;
  RideModel? ride;
  String? tripType;
  String? paymentMethod;
  DateTime selectedDate = DateTime.now();
  final bookingService = BookingService();
  final rideService = RideService();
  List<Map<String, dynamic>> stops = [];
  String? selectedStop;
  bool isPickup = true;
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
      isPickup = ride?.route['drop'] == "NSBM Green University";

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
        if (tripType == "Round-trip") {
          currentPrice = currentPrice * 2;
        }
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text("Booking",
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Column(
                    children: [
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
                    ],
                  ),
                  SizedBox(height: 25),
                  if (stops.isNotEmpty) ...[
                    Text(
                      "Select ${isPickup ? "Pickup" : "Drop"} Spot",
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
                  Text("Select Trip Type",
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      tripTypeRadio("One-Way", theme),
                      tripTypeRadio("Round-trip", theme),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text("Select Booking Dates",
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 10)),
                      Text("Day"),
                      SizedBox(width: 30),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          margin: EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Text("Payment Method",
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        paymentMethodRadio("Cash", theme),
                        paymentMethodRadio("Card", theme),
                        paymentMethodRadio("Pay Later", theme),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: paymentMethodRadio("Current Balance", theme),
                  ),
                  SizedBox(height: 35),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
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

  Widget tripTypeRadio(String type, ThemeData theme) {
    return Row(
      children: [
        Radio(
          value: type,
          groupValue: tripType,
          activeColor: theme.colorScheme.primary,
          onChanged: (value) {
            setState(() {
              tripType = value.toString();
              updatePrice();
            });
          },
        ),
        Text(type),
      ],
    );
  }

  Widget paymentMethodRadio(String method, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          value: method,
          groupValue: paymentMethod,
          activeColor: theme.colorScheme.primary,
          onChanged: (value) {
            setState(() {
              paymentMethod = value.toString();
            });
          },
        ),
        Text(method),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void handleBooking() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (tripType == null) {
      Helpers.showMessage(context, 'Please select a trip type');
      return;
    }
    if (paymentMethod == null) {
      Helpers.showMessage(context, 'Please select a payment method');
      return;
    }
    if (selectedDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      Helpers.showMessage(context, 'Please select a valid date');
      return;
    }

    String userId = userProvider.user!.userId;
    String name = userProvider.user!.name;
    double amount = currentPrice;

    String pickup = isPickup ? selectedStop! : "NSBM Green University";
    String drop = isPickup ? "NSBM Green University" : selectedStop!;

    bool isSuccess = await bookingService.createSingleBooking(
        rideId!, userId, name, paymentMethod!, tripType!, selectedDate, amount, pickup, drop);

    if (isSuccess) {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/student/home');
      });
      Helpers.showMessage(context, 'Booking successful');
    } else {
      if (paymentMethod == 'Current Balance') {
        Helpers.showMessage(context, 'Insufficient funds');
      } else {
        Helpers.showMessage(context, 'Booking failed! Please try again');
      }
    }
  }
}
