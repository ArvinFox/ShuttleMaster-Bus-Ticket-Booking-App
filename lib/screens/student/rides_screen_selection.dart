import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/components/rides_info_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shuttlemaster/models/ride_model.dart';

class RidesScreenSelection extends StatefulWidget {
  final String busType;

  const RidesScreenSelection({super.key, required this.busType});

  @override
  _RidesScreenSelectionState createState() => _RidesScreenSelectionState();
}

class _RidesScreenSelectionState extends State<RidesScreenSelection> {
  String? _pickupLocation;
  String? _dropLocation;

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropController = TextEditingController();

  List<Map<String, String>> timetable = [];

  bool isLoading = true;
  List<RideModel> privateRides = [];
  List<RideModel> filteredRides = [];

  List<String> _locationSuggestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.busType != "Private Bus") {
      fetchTimetable();
    } else {
      fetchPrivateRides();
    }
  }

  void fetchTimetable() {
    setState(() {
      isLoading = true;
    });

    String collectionPath;

    if (widget.busType == "NSBM Bus") {
      collectionPath = 'bus_timetables/nsbm_bus/timetable';
    } else {
      collectionPath = 'bus_timetables/public_transport/timetable';
    }

    FirebaseFirestore.instance
        .collection(collectionPath)
        .get()
        .then((querySnapshot) {
      List<Map<String, String>> fetchedTimetable = [];
      for (var doc in querySnapshot.docs) {
        DateTime time = (doc["time"] as Timestamp).toDate();
        String formattedTime = DateFormat('h:mm a').format(time);

        fetchedTimetable.add({
          "busNo": doc["busNo"],
          "start": doc["start"],
          "end": doc["end"],
          "time": formattedTime,
        });
      }
      setState(() {
        timetable = fetchedTimetable;
        isLoading = false;
      });
    }).catchError((error) {
      print("Error fetching timetable: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  void fetchPrivateRides() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('rides').get();

      List<RideModel> rides = snapshot.docs.map((doc) {
        return RideModel.fromFirestore(doc);
      }).toList();

      // Extract all unique pickup and drop locations (except NSBM)
      Set<String> locationSet = {};
      for (var ride in rides) {
        final pickup = ride.route['pickup'] ?? '';
        final drop = ride.route['drop'] ?? '';
        if (pickup.isNotEmpty && pickup != "NSBM Green University") {
          locationSet.add(pickup);
        }
        if (drop.isNotEmpty && drop != "NSBM Green University") {
          locationSet.add(drop);
        }
      }

      rides.shuffle(); // Show random rides on load

      setState(() {
        privateRides = rides;
        filteredRides = rides;
        _locationSuggestions = locationSet.toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching private rides: $e");
    }
  }

  void _searchRides() {
    if (_pickupLocation == null || _dropLocation == null) return;

    setState(() {
      filteredRides = privateRides.where((ride) {
        return ride.route['pickup'] == _pickupLocation &&
            ride.route['drop'] == _dropLocation;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: 'Rides', showLeading: true),
      body: SafeArea(
        child: widget.busType == "Private Bus"
            ? _buildRideSearch()
            : _buildTimetableUI(),
      ),
    );
  }

  Widget _buildRideSearch() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.only(top: 15),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    _buildSearchFields(),
                    SizedBox(height: 20),
                    filteredRides.isEmpty
                        ? Text("No rides found.")
                        : Column(
                            children: filteredRides.map((ride) {
                              return RideInfoCard(
                                busNo: ride.busNo,
                                startPoint: ride.route['pickup']!,
                                endPoint: ride.route['drop']!,
                                time: DateFormat('h:mm a')
                                    .format(ride.departureTime),
                                price: "Rs. ", // Include the price in database
                                seatAvailability:
                                    ride.availableSeats > 0 ? "Yes" : "No",
                                btnShown: ride.availableSeats > 0,
                              );
                            }).toList(),
                          )
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildTimetableUI() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
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
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blueAccent),
                      headingTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      dataRowHeight: 60,
                      columns: const [
                        DataColumn(label: Text('Bus No')),
                        DataColumn(label: Text('Start Point')),
                        DataColumn(label: Text('End Point')),
                        DataColumn(label: Text('Time')),
                      ],
                      rows: timetable.map((ride) {
                        return DataRow(
                          color: MaterialStateProperty.all(
                            timetable.indexOf(ride) % 2 == 0
                                ? Colors.grey[200]!
                                : Colors.white,
                          ),
                          cells: [
                            DataCell(Text(ride["busNo"]!)),
                            DataCell(Text(ride["start"]!)),
                            DataCell(Text(ride["end"]!)),
                            DataCell(Text(ride["time"]!)),
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
            onPressed: _searchRides,
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
            return _locationSuggestions.where((String option) {
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
                _dropController.text = _dropLocation!;
              } else {
                _dropLocation = selection;
                _dropController.text = selection;

                _pickupLocation = "NSBM Green University";
                _pickupController.text = _pickupLocation!;
              }
            });
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            textEditingController.text = controller.text;

            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  if (isPickup) {
                    _pickupLocation = value;
                  } else {
                    _dropLocation = value;
                  }
                });
              },
            );
          },
        ),
      ],
    );
  }
}
