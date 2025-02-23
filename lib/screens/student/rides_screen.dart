import 'package:flutter/material.dart';

class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Rides', 
          style: TextStyle(
            fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
          top: 15,
        ),
        child: Center(
          child: Column(
            children: [
              _buildRideOption('Private Bus','assets/images/privateBus.jpg',),
              _buildRideOption('NSBM Bus','assets/images/nsbmBus.png',),
              _buildRideOption('Public Transport','assets/images/privateBus.jpg',),
            ],
            ),
          ), 
        ),
      ),
    );
  }
}

Widget _buildRideSearch() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent, width: 1),
      ),
      child: Column(
        children: [
          _buildAutoCompleteTextField("Pickup Location"),

          SizedBox(height: 10),

          _buildAutoCompleteTextField("Drop Location"),

          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            child: Text("Search", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    ),
  );
}

Widget _buildAutoCompleteTextField(String hintText) {
  return Autocomplete<String>(
    optionsBuilder: (TextEditingValue textEditingValue) {
      if (textEditingValue.text.isEmpty) {
        return const Iterable<String>.empty();
      }
      return _suggestions.where((String option) {
        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
      });
    },
    onSelected: (String selection) {
      print('Selected: $selection');
    },
    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
      return TextField(
        controller: controller,
        focusNode: focusNode,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.lightBlue, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      );
    },
  );
}

final List<String> _suggestions = [
  "NSBM Green University",
  "Colombo Fort",
  "Pettah",
  "Malabe",
  "Kottawa",
  "Maharagama",
  "Homagama",
  "Nugegoda",
  "Borella",
  "Rajagiriya",
];


Widget _buildRideOption(String text, String imagePath) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Material(
          borderRadius: BorderRadius.circular(15),
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
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
