import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/models/user_model.dart';
import 'package:shuttlemaster/providers/user_provider.dart';

class ViewProfileStudent extends StatefulWidget {
  const ViewProfileStudent({super.key});

  @override
  State<ViewProfileStudent> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfileStudent> {

  void _showLogoutConfirmation(BuildContext context){
    final theme = Theme.of(context);

    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text("Confirm Logout", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 300,
            child: Text(
              "Are you sure you want to logout ?", 
              style: theme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              }, 
              child: Text("Cancel", style: TextStyle(color: theme.colorScheme.primary))
            ),
            TextButton(
              onPressed: (){
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/select-role',(Route<dynamic> route) => false);
              }, 
              child: Text("Logout", style: TextStyle(color: Colors.redAccent))
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomMainAppbar(title: "Profile", showLeading: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 35, horizontal: 40),
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading) {
                return Center(child: CircularProgressIndicator());
              }
        
              final user = userProvider.user as PassengerModel;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(Icons.person, size: 60, color: theme.colorScheme.onPrimary),
                  ),
                  SizedBox(height: 30),
        
                  // Profile Details
                  _profileItem(Icons.person, user.name, theme),
                  _profileItem(Icons.phone, user.phone, theme),
                  _profileItem(Icons.email, user.email, theme),
        
                  SizedBox(height: 40),
        
                  ElevatedButton(
                    onPressed: () {
                      //logout function
                      _showLogoutConfirmation(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding:EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Logout",
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String label, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 36),
          SizedBox(width: 25),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
