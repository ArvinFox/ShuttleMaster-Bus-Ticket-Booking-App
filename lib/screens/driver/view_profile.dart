import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ViewProfileDriver extends StatefulWidget {
  const ViewProfileDriver({super.key});

  @override
  State<ViewProfileDriver> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfileDriver> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        leadingWidth: 40,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 35, horizontal: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 30),

            // Profile Details
            ProfileItem(icon: Icons.person, label: "Full Name"),
            ProfileItem(icon: Icons.location_on, label: "Address"),
            ProfileItem(icon: Icons.phone, label: "Mobile Number"),
            ProfileItem(icon: Icons.email, label: "Email Address"),

            SizedBox(height: 50),

            ElevatedButton(
              onPressed: () {
                // logout functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(
                    horizontal: 100, vertical: 15), // Adjust width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Logout",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Profile Item Widget
class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const ProfileItem({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 36),
          SizedBox(width: 25),
          Text(label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
