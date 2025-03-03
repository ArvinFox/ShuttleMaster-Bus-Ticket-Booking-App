import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({super.key});

  @override
  State<TripHistory> createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Text(
          "Trip History",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.popAndPushNamed(context, '/driver-profile');
          },
        ),
        leadingWidth: 40,
      ),
      body: _buildTripHistoryCard("25 Jan 2025", "18:00 PM", 25, 30000),
    );
  }
}

Widget _buildTripHistoryCard(String date, String completedTime, int travelDistance, double income) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Card(
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFFCACACA).withOpacity(0.20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.done,
                            color: const Color.fromARGB(255, 28, 150, 34),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Completed",
                            style: TextStyle(
                                fontSize: 20,
                                color: const Color.fromARGB(255, 28, 150, 34),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        date,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Text(
                    completedTime,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Travel Distance - $travelDistance Km",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  _buildLocation("Kadawatha 18:00 PM"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: 2,
                      height: 40,
                      color: Colors.black,
                    ),
                  ),
                  _buildLocation("NSBM 17:00 PM"),
                  Divider(color: Colors.black),
                ],
              ),
              Text(
                "Income : Rs.${income.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildLocation(String location) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        Icon(Icons.circle_outlined),
        SizedBox(
          width: 10,
        ),
        Text(
          location,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
