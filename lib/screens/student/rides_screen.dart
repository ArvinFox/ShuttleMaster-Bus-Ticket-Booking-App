import 'package:flutter/material.dart';

class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

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
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 15),
            child: Center(
              child: Column(
                children: [
                  _buildRideOption(
                    'Private Bus',
                    'assets/images/privateBus.jpg',
                    () => Navigator.pushNamed(context, '/privateBusScreen'),
                  ),
                  _buildRideOption(
                    'NSBM Bus',
                    'assets/images/nsbmBus.png',
                    () => Navigator.pushNamed(context, '/NSBM-Bus'),
                    //Path to timetables
                  ),
                  _buildRideOption(
                    'Public Transport',
                    'assets/images/privateBus.jpg',
                    () => Navigator.pushNamed(context, '/public-transport'),
                    //Path to timetables
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildRideOption(String text, String imagePath, VoidCallback onTap) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          borderRadius: BorderRadius.circular(15),
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              height: 210,
              child: Container(
                height: 210,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 15),
    ],
  );
}
