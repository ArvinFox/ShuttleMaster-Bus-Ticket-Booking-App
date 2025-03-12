import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttlemaster/components/custom_header.dart';
import 'package:shuttlemaster/constants/app_config.dart';
import 'package:shuttlemaster/models/user_model.dart';
import 'package:shuttlemaster/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _handleAutoLogin();
    });
  }

  Future<void> _handleAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool? staySignedIn = prefs.getBool(AppConfig.staySignedInKey);
    String? userId = prefs.getString(AppConfig.userIdKey);
    String? userRole = prefs.getString(AppConfig.userRoleKey);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (staySignedIn == true && userId != null && userRole != null) {
      if (userProvider.user == null && !userProvider.isLoading) {
        await userProvider.fetchUser(userId, userRole);
      }
    } else {
      await _checkStaySignedInPreference();
    }
  }

  Future<void> _checkStaySignedInPreference() async {
    final prefs = await SharedPreferences.getInstance();
    bool? staySignedIn = prefs.getBool(AppConfig.staySignedInKey);

    if (staySignedIn == null) {
      _showStaySignedInDialog();
    }
  }

  void _showStaySignedInDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Stay Signed In?"),
          content: Text("Would you like to stay signed in on this device for easier access next time?"),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(AppConfig.staySignedInKey, false);
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(AppConfig.staySignedInKey, true);

                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (userProvider.user != null) {
                  await prefs.setString(AppConfig.userIdKey, userProvider.user!.userId);
                  await prefs.setString(AppConfig.userRoleKey, userProvider.user!.role);
                }

                Navigator.of(context).pop();
              },
              child: Text("Yes"),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: -24),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 35,
          ),
          child: Column(
            children: [
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final user = userProvider.user;
                  return CustomHeader(
                    role: AppConfig.passengerRole,
                    name: user?.name ?? "User",
                    accountBalance: (user as PassengerModel).walletBalance,
                  );
                },
              ),
              _buildMyRides(),
              _buildQuickAccessGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyRides() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Rides",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.asset("assets/images/my-rides.png", height: 50),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "NA 1090",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          Text("Kadawatha"),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey),
                          Text("NSBM"),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Access",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            _buildQuickAccessButton(context, "View History", Icons.history, "/view-traveling-history"),
            _buildQuickAccessButton(context, "Book Now", Icons.book_online, "/privateBusScreen"),
            _buildQuickAccessButton(context, "Pay Later", Icons.payment, "/pay-later"),
            _buildQuickAccessButton(context, "Cancel a Booking", Icons.cancel, "/traveling-history"),
            _buildQuickAccessButton(context, "Top up Account", Icons.account_balance_wallet, "/top-up-account"),
            _buildQuickAccessButton(context, "Customer Support", Icons.support_agent, ""),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(BuildContext context, String label, IconData icon, String route) {
    return Card(
      color: Colors.grey[100],
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.blue[700]),
              SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
