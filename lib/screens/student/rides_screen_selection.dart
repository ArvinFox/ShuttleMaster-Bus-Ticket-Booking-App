import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/rides_info_card.dart';

class RidesScreenSelection extends StatefulWidget {
  final String busType;

  const RidesScreenSelection({super.key, required this.busType});

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

  List<Map<String, String>> timetable = [];

  @override
  void initState() {
    super.initState();
    if (widget.busType != "Private Bus") {
      fetchTimetable();
    }
  }

  void fetchTimetable() {
  print("Fetching timetable for: ${widget.busType}");
  setState(() {
    timetable = [
      if (widget.busType == "NSBM Bus") ...[
        {"busNo": "NSBM Bus 1", "start": "Homagama", "end": "NSBM", "time": "7:30 AM"},
        {"busNo": "NSBM Bus 2", "start": "Colombo", "end": "NSBM", "time": "9:00 AM"},
        {"busNo": "NSBM Bus 3", "start": "Colombo", "end": "NSBM", "time": "9:00 AM"},
      ] else if (widget.busType == "Public Transport") ...[
        {"busNo": "NA 0019", "start": "Pettah", "end": "NSBM", "time": "6:45 AM"},
        {"busNo": "NC 0018", "start": "Kottawa", "end": "NSBM", "time": "8:15 AM"},
      ]
    ];
  });
}

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: Text('Rides'),
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
    ),
    body: SafeArea(
      child: widget.busType == "Private Bus" 
        ? _buildRideSearch() 
        : _buildTimetableUI(),
    ),
  );
}

  Widget _buildRideSearch() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 15),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _buildSearchFields(),
              SizedBox(height: 20),
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
    );
  }

Widget _buildTimetableUI() {
  return Padding(
    padding: EdgeInsets.all(15),
    child: LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: screenWidth,
            ),
            child: DataTable(
              columnSpacing: 20,
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueAccent), // Header row color
              headingTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              dataRowHeight: 60,
              columns: const [
                DataColumn(label: Text('Bus No', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                DataColumn(label: Text('Start Point', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                DataColumn(label: Text('End Point', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
                DataColumn(label: Text('Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),)),
              ],
              rows: timetable.map((ride) {
                return DataRow(
                  color: MaterialStateProperty.all(
                    timetable.indexOf(ride) % 2 == 0 ? Colors.grey[200]! : Colors.white,
                  ), // Alternate row colors
                  cells: [
                    DataCell(Text(ride["busNo"]!, style: TextStyle(fontSize: 14))),
                    DataCell(Text(ride["start"]!, style: TextStyle(fontSize: 14))),
                    DataCell(Text(ride["end"]!, style: TextStyle(fontSize: 14))),
                    DataCell(Text(ride["time"]!, style: TextStyle(fontSize: 14))),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    ),
  );
}


  Widget _buildSearchFields() {
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
    TextEditingController controller = isPickup ? _pickupController : _dropController;

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
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
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
          fieldViewBuilder: (context, textController, focusNode, onEditingComplete) {
            textController.text = controller.text;
            return TextField(
              controller: textController,
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
              ),
            );
          },
        ),
      ],
    );
  }
}
