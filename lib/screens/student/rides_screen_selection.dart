import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/rides_info_card.dart';

class RidesScreenSelection extends StatefulWidget {
  const RidesScreenSelection({super.key});

  @override
  _RidesScreenSelectionState createState() => _RidesScreenSelectionState();
}

class _RidesScreenSelectionState extends State<RidesScreenSelection> {
  final List<String> _suggestions = [
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

  String? _pickupLocation;
  String? _dropLocation;

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Rides',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 15),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  _buildRideSearch(),
                  SizedBox(
                    height: 20,
                  ),
                  RideInfoCard(
                    busNo: "NA 0090",
                    startPoint: "Kadawatha",
                    endPoint: "NSBM",
                    time: "8:00 AM",
                    price: "Rs. 300.00",
                    seatAvailability: "Yes",
                    btnShown: true,
                  ),
                  RideInfoCard(
                    busNo: "NA 0090",
                    startPoint: "Kadawatha",
                    endPoint: "NSBM",
                    time: "8:00 AM",
                    price: "Rs. 300.00",
                    seatAvailability: "No",
                    btnShown: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRideSearch() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blueAccent, width: 1),
      ),
      child: Column(
        children: [
          _buildAutoCompleteTextField("Pickup Location", true),
          SizedBox(height: 10),
          _buildAutoCompleteTextField("Drop Location", false),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              print("Pickup: $_pickupLocation, Drop: $_dropLocation");
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
    );
  }

  Widget _buildAutoCompleteTextField(String hintText, bool isPickup) {
    TextEditingController controller =
        isPickup ? _pickupController : _dropController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPickup ? "Pickup " : "Drop ",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return _suggestions.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            setState(() {
              if (isPickup) {
                _pickupLocation = selection;
                _pickupController.text = selection;
                _dropLocation = "NSBM Green University";
                _dropController.text = "NSBM Green University";
              } else {
                _dropLocation = selection;
                _dropController.text = selection;
                _pickupLocation = "NSBM Green University";
                _pickupController.text = "NSBM Green University";
              }
            });
          },
          fieldViewBuilder:
              (context, textController, focusNode, onEditingComplete) {
            textController.text = controller.text;

            return TextField(
              controller: textController,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              onChanged: (value) {
                if (value == "NSBM Green University") {
                  // Prevent partial deletion by re-selecting text
                  textController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: value.length,
                  );
                } else if (_pickupLocation == "NSBM Green University" &&
                    isPickup &&
                    value.length < "NSBM Green University".length) {
                  // If user tries to erase NSBM from Pickup, clear both fields
                  setState(() {
                    _pickupLocation = null;
                    _dropLocation = null;
                    _pickupController.clear();
                    _dropController.clear();
                  });
                } else if (_dropLocation == "NSBM Green University" &&
                    !isPickup &&
                    value.length < "NSBM Green University".length) {
                  // If user tries to erase NSBM from Drop, clear both fields
                  setState(() {
                    _pickupLocation = null;
                    _dropLocation = null;
                    _pickupController.clear();
                    _dropController.clear();
                  });
                }
              },
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
            );
          },
        ),
      ],
    );
  }
}
