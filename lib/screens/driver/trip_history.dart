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
      appBar: CustomMainAppbar(title: 'Trip History', showLeading: true),
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
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: ridesProvider.rides.length,
              itemBuilder: (context, index) {
                final ride = ridesProvider.rides[index];

                if(ride.status == 'Completed'){
                  return _buildTripCompletedCard(
                    Formatters.formatDate(ride.departureTime), 
                    Formatters.formatTime(ride.departureTime), 
                    ride.route['pickup'] ?? 'Pickup',
                    ride.route['drop'] ?? 'Drop',
                    ride.totalIncome, 
                    (ride.completedTime != null
                      ? '${Formatters.formatDate(ride.completedTime!)}  ${Formatters.formatTime(ride.completedTime!)}'
                      : 'N/A'),
                    ride.reservedSeats
                  );
                }
                return null;
              },
            );
          }
        },
      ),
    );
  }
}

Widget _buildTripCompletedCard(String departureDate,String time,String pickup,String drop,double income, String? completedDateTime,int seats) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Card(
      child: Container(
        width: double.infinity,
        height: 330,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFFCACACA).withOpacity(0.20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.done,
                        color: Color.fromARGB(255, 28, 150, 34)
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Completed",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 28, 150, 34)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Route",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$pickup - $drop',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Departure Date",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    departureDate,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Departure Time",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reserved Seats",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    seats.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Income",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Rs.${income.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.black),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Completed Date & time",
                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                  ),
                  Text(
                    completedDateTime!,
                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
