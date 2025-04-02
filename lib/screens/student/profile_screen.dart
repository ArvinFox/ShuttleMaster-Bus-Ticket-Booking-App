import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/providers/theme_provider.dart';
import 'package:shuttlemaster/providers/user_provider.dart';

class ProfileScreenStuent extends StatefulWidget {
  const ProfileScreenStuent({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreenStuent> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
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
                          color: theme.colorScheme.background, width: 4), // White border
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.background,
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
                            Text(user!.name, style: theme.textTheme.bodyLarge)),
                    Center(
                        child: Text(user.phone,
                            style:
                                theme.textTheme.bodyMedium?.copyWith(color: Colors.grey))),
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
                  Text('Dark Mode', style: theme.textTheme.bodyMedium),
                  Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(),
                  ),
                ],
              ),
            ),
            const Divider(), // Divider below dark mode switch
            const SizedBox(height: 10),

            // List Items
            _buildListItem(
                Icons.person, 'View Profile', "/student/view-profile", theme),
            _buildListItem(
                Icons.history, 'Travelling History', "/traveling-history", theme),
            _buildListItem(Icons.account_balance_wallet, 'Top up Account',
                "/top-up-account", theme),
            _buildListItem(Icons.support_agent, 'Help & Support', "", theme),
            _buildListItem(Icons.info_outline, 'About Us', "/about-us", theme),

            // Footer
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Center(
                child: Column(
                  children: [
                    Text('All rights reserved. Developed by Group 10', style: theme.textTheme.bodySmall),
                    Text('(Batch 12 UOP - NSBM)', style: theme.textTheme.bodySmall),
                    Text('App version - 1.0.0', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, String route, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Text(title, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
