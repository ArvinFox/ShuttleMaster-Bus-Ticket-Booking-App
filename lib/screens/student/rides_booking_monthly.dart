import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/rides_info_card.dart';

class RidesScreenMonthly extends StatefulWidget {
  const RidesScreenMonthly({super.key});

  @override
  RidesScreenState createState() => RidesScreenState();
}

class RidesScreenState extends State<RidesScreenMonthly> {
  String? selectedPayment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Rides',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              "Join as a monthly member",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Ride Info Card
            RideInfoCard(
              busNo: "NA 0090",
              startPoint: "Kadawatha",
              endPoint: "NSBM",
              time: "8:00 AM",
              price: "Rs. 300.00",
              seatAvailability: "Yes",
            ),

            SizedBox(height: 25),
            Text(
              "Payment Method (Recurring)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Payment Options
            _buildPaymentOption("Cash"),
            _buildPaymentOption("Card"),
            _buildPaymentOption("Current Balance"),

            SizedBox(height: 40),

            // OK Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  print("Selected Payment: $selectedPayment");
                },
                child: Text("OK",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String option) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Radio<String>(
          value: option,
          groupValue: selectedPayment,
          activeColor: Colors.blueAccent,
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
}
