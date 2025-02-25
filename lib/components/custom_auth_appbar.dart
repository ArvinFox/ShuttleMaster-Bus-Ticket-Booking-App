import 'package:flutter/material.dart';

class CustomAuthAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAuthAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: Colors.grey,
      backgroundColor: Colors.white,
      leadingWidth: 100,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Row(
          children: [
            SizedBox(width: 6),
            Icon(Icons.arrow_back),
            SizedBox(width: 8),
            Text("Back", style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
      flexibleSpace: Container(color: Colors.white),
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}