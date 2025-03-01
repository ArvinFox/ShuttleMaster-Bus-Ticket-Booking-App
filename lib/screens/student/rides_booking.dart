import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RidesBooking extends StatelessWidget {
  const RidesBooking({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookingScreen(),
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> {
  String tripType = "";
  String paymentMethod = "";
  DateTime selectedDate = DateTime(2025, 2, 10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rides",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        leadingWidth: 40,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text("Booking",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                    infoRow("Start Point", "Kadawatha"),
                    infoRow("End Point", "NSBM"),
                    infoRow("Time", "8:00 AM"),
                    infoRow("Price", "Rs. 300.00"),
                    infoRow("Seat Availability", "Yes"),
                  ],
                ),
              ),
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
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            Wrap(
              children: [
                paymentMethodRadio("Cash"),
                paymentMethodRadio("Card"),
                paymentMethodRadio("Pay Later"),
                paymentMethodRadio("Current Balance"),
              ],
            ),
            SizedBox(height: 35),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: context => const ))
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

  Widget infoRow(String title, String value) {
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
}
