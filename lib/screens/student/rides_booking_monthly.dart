import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RidesBookingMonthly extends StatelessWidget {
  const RidesBookingMonthly({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RidesScreen(),
    );
  }
}

class RidesScreen extends StatefulWidget {
  const RidesScreen({super.key});

  @override
  RidesScreenState createState() => RidesScreenState();
}

class RidesScreenState extends State<RidesScreen> {
  String? selectedPayment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Rides", style: TextStyle(color: Colors.white)),
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
            Card(
              color: Colors.grey[200],
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_bus, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Bus No",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                        Spacer(),
                        Text("NA 0090",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      ],
                    ),
                    Divider(),
                    infoRows("Start Point", "Kadawatha"),
                    infoRows("End Point", "NSBM"),
                    infoRows("Time", "8:00 AM"),
                    infoRows("Price", "Rs. 300.00"),
                    infoRows("Seat Availability", "Yes"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),
            Text(
              "Payment Method (Recurring)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildPaymentOption("Cash"),
            _buildPaymentOption("Card"),
            _buildPaymentOption("Current Balance"),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {},
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

  Widget infoRows(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$title - ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
