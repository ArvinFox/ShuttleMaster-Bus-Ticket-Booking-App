import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_header.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 35,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeader(role: 'driver'),
            SizedBox(height: 15,),

            Text('Send Alerts', style: TextStyle(fontSize: 20),),
            Divider(thickness: 2,),
            SizedBox(height: 5,),

            _buildAlertItem("The bus will be leaving soon..."),
            _buildAlertItem("The bus has arrived at your destination!"),
            _buildAlertItem("This is an alert!"),
            _buildAlertItem("Are you coming today?"),
            
          ],
        )
      )
    );
  }

  Container _buildAlertItem(String alert) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin:EdgeInsets.only(top: 10),
      padding: EdgeInsets.only(left: 25),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(50),
        

      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              // 'The bus should be driven rn...',
              alert, 
              style: TextStyle(fontSize: 20)
            )
          ),
          // SizedBox(width: 10,)
          Container(
            height: 80,
            width: 80,
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.blue,

            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset("assets/icons/send.png",),
            )
            
          )
        ],
      ),
    );
  }
}