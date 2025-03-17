import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/providers/rides_provider.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/utils/formatters.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({super.key});

  @override
  State<TripHistory> createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driverId = Provider.of<UserProvider>(context, listen: false).user?.userId;

      if (driverId != null) {
        Provider.of<RidesProvider>(context, listen: false).fetchRideHistory(driverId);
      } else {
        print("driver Id not found");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: 'Trip History'),
      body: Consumer<RidesProvider>(
        builder: (context, ridesProvider, child) {
          if (ridesProvider.rides.isEmpty) {
            return Center(child: Text("No trip history available"));
          } 
          else 
          {
            if (ridesProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: ridesProvider.rides.length,
              itemBuilder: (context, index) {
                final ride = ridesProvider.rides[index];
                return _buildTripHistoryCard(
                  Formatters.formatDate(ride.completedTime),
                  Formatters.formatTime(ride.completedTime),
                  ride.distance.toInt(),
                  ride.totalIncome,
                  ride.route['pickup'] ?? 'Pickup',
                  ride.route['drop'] ?? 'Drop',
                  Formatters.formatTime(ride.departureTime),
                );
              },
            );
          }
        },
      ),
    );
  }
}

Widget _buildTripHistoryCard(String date, String completedTime,int travelDistance, double income, String pickup, String drop, String scheduleTime) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Card(
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFFCACACA).withOpacity(0.20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.done,
                            color: const Color.fromARGB(255, 28, 150, 34),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Completed",
                            style: TextStyle(
                              fontSize: 20,
                              color: const Color.fromARGB(255, 28, 150, 34),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      Text(
                        date,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 16,fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Text(
                    completedTime,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Travel Distance - $travelDistance Km",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  // ignore: prefer_interpolation_to_compose_strings
                  _buildLocation(pickup + '  ' + scheduleTime),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: 2,
                      height: 40,
                      color: Colors.black,
                    ),
                  ),
                  // ignore: prefer_interpolation_to_compose_strings
                  _buildLocation(drop + '  ' + completedTime),
                  Divider(color: Colors.black),
                ],
              ),
              Text(
                "Income : Rs.${income.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildLocation(String location) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      children: [
        Icon(Icons.circle_outlined),
        SizedBox(
          width: 10,
        ),
        Text(
          location,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}
