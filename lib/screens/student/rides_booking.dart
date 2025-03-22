import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/components/rides_info_card.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/services/booking_service.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  String? tripType;
  String? paymentMethod;
  DateTime selectedDate = DateTime.now();
  final bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: 'Rides'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text("Booking",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Column(
                children: [
                  RideInfoCard(
                    busNo: "NA 0090",
                    startPoint: "Kadawatha",
                    endPoint: "NSBM",
                    time: "8:00 AM",
                    price: "Rs. 300.00",
                    seatAvailability: "Yes",
                  ),
                ],
              ),
              SizedBox(height: 25),
              Text("Select Trip Type",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  tripTypeRadio("One-Way"),
                  tripTypeRadio("Round-trip"),
                ],
              ),
              SizedBox(height: 16),
              Text("Select Booking Dates",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Text("Payment Method",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    paymentMethodRadio("Cash"),
                    paymentMethodRadio("Card"),
                    paymentMethodRadio("Pay Later"),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: paymentMethodRadio("Current Balance"),
              ),
              SizedBox(height: 35),
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

  Widget tripTypeRadio(String type) {
    return Row(
      children: [
        Radio(
          value: type,
          groupValue: tripType,
          activeColor: Colors.blueAccent,
          onChanged: (value) {
            setState(() {
              tripType = value.toString();
            });
          },
        ),
        Text(type),
      ],
    );
  }

  Widget paymentMethodRadio(String method) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          value: method,
          groupValue: paymentMethod,
          activeColor: Colors.blueAccent,
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

    String rideId = '1';
    String userId = userProvider.user!.userId;
    double amount = 300;

    bool isSuccess = await bookingService.createSingleBooking(
        rideId, userId, paymentMethod!, tripType!, selectedDate, amount);

    if (isSuccess) {
      Helpers.showMessage(context, 'Booking successful');
      Future.delayed(Duration(seconds: 1), () {
        // Navigator.popUntil(context, ModalRoute.withName('/student/home'));
        Navigator.pushReplacementNamed(context, '/student/home');
      });
    } else {
      if (paymentMethod == 'Current Balance') {
        Helpers.showMessage(context, 'Insufficient funds');
      } else {
        Helpers.showMessage(context, 'Booking failed! Please try again');
      }
    }
  }
}
