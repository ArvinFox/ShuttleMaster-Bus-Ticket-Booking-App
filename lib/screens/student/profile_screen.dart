import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/providers/user_provider.dart';

class ProfileScreenStuent extends StatefulWidget {
  const ProfileScreenStuent({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreenStuent> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final user = userProvider.user;
                return Column(
                  children: [
                    const SizedBox(
                        height: 50), // Space to push content down after avatar
                    Center(
                        child:
                            Text(user!.name, style: TextStyle(fontSize: 20))),
                    Center(
                        child: Text(user.phone,
                            style:
                                TextStyle(fontSize: 16, color: Colors.grey))),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),

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
            _buildListItem(
                Icons.person, 'View Profile', "/student/view-profile"),
            _buildListItem(
                Icons.history, 'Travelling History', "/traveling-history"),
            _buildListItem(Icons.account_balance_wallet, 'Top up Account',
                "/top-up-account"),
            _buildListItem(Icons.support_agent, 'Help & Support', ""),
            _buildListItem(Icons.info_outline, 'About Us', "/about-us"),

            // Footer
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Center(
                child: Column(
                  children: [
                    Text('All rights reserved. Developed by Group 10'),
                    Text('(Batch 12 UOP - NSBM)'),
                    Text('App version - 1.0.0'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
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
