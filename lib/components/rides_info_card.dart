import 'package:flutter/material.dart';

class RideInfoCard extends StatelessWidget {
  final String busNo;
  final String startPoint;
  final String endPoint;
  final String time;
  final String price;
  final String seatAvailability;
  final bool btnShown;

  const RideInfoCard({
    super.key,
    required this.busNo,
    required this.startPoint,
    required this.endPoint,
    required this.time,
    required this.price,
    required this.seatAvailability,
    this.btnShown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_bus, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  "Bus No",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Spacer(),
                Text(
                  busNo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Divider(),
            _infoRow("Start Point", startPoint),
            _infoRow("End Point", endPoint),
            _infoRow("Time", time),
            _infoRow("Price", price),
            _infoRow("Seat Availability", seatAvailability),
            if (btnShown) ...[
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton("Book Now", Colors.blue, () {
                    Navigator.pushNamed(context, '/book-now');
                  }),
                  _actionButton("Join", Colors.green, () {
                    Navigator.pushNamed(context, '/monthly-book');
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$title - ",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(text, style: TextStyle(fontSize: 16)),
    );
  }
}
