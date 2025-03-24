import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/models/user_model.dart';
import 'package:shuttlemaster/providers/user_provider.dart';

class ViewProfileDriver extends StatefulWidget {
  const ViewProfileDriver({super.key});

  @override
  State<ViewProfileDriver> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfileDriver> {
  void _showLogoutConfirmation(BuildContext context){
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: SizedBox(
            width: 300,
            child: Text("Are you sure you want to logout ?")
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              }, 
              child: Text("Cancel")
            ),
            TextButton(
              onPressed: (){
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/select-role',(Route<dynamic> route) => false);
              }, 
              child: Text("Logout")
            )
          ],
        );
      }
    );
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: "Profile"),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 35, horizontal: 60),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            final user = userProvider.user as DriverModel;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                SizedBox(height: 30),

                // Profile Details
                _profileItem(Icons.person, user.name),
                _profileItem(Icons.phone, user.phone),
                SizedBox(height: 100),

                ElevatedButton(
                  onPressed: () {
                    //logout function
                    _showLogoutConfirmation(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding:EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Logout",
                    style: TextStyle(fontSize: 18, color: Colors.white)
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 36),
          SizedBox(width: 25),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)
            ),
          ),
        ],
      ),
    );
  }
}
