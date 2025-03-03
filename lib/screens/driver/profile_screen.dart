import 'package:flutter/material.dart';

class ProfileScreenDriver extends StatefulWidget {
  const ProfileScreenDriver({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreenDriver> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Banner with Profile Picture
            Stack(
              clipBehavior: Clip.none, // Allows avatar to overflow
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180, // Height of the blue banner
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40, // Keeps avatar overlapping
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white, width: 4), // White border
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_outline,
                          size: 60, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 50), // Space to push content down after avatar
            const Center(
                child: Text('@UserName', style: TextStyle(fontSize: 20))),
            const Center(
                child: Text('07xxxxxxxx',
                    style: TextStyle(fontSize: 16, color: Colors.grey))),
            const SizedBox(height: 20),

            // Dark Mode Switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dark Mode'),
                  Switch(
                    value: _darkMode,
                    onChanged: (bool value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(), // Divider below dark mode switch
            const SizedBox(height: 10),

            // List Items
            _buildListItem(Icons.person, 'View Profile', () {}),
            _buildListItem(Icons.history, 'Traveling History', () {}),
            _buildListItem(Icons.history, 'Top up Account', () {}),
            _buildListItem(Icons.headset_mic, 'Help & Support', () {}),
            _buildListItem(Icons.info_outline, 'About Us', () {}),

            // Footer
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Center(
                child: Column(
                  children: [
                    Text('All rights reserved. Developed by Group 10'),
                    Text('(Batch 12 UOP - NGSM)'),
                    Text('App version - 1.0.0'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline), label: 'Trip Info'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        currentIndex: 3, // Account selected
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 16),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
