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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomMainAppbar(title: 'Trip History', showLeading: true),
      body: SingleChildScrollView(
        child: Consumer<RidesProvider>(
          builder: (context, ridesProvider, child) {
            if (ridesProvider.rides.isEmpty) {
              return Center(child: Text("No trip history available", style: theme.textTheme.bodyMedium));
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
                      context,
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
      ),
    );
  }
}

Widget _buildTripCompletedCard(BuildContext context, String departureDate,String time,String pickup,String drop,double income, String? completedDateTime,int seats) {
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.all(10),
    child: Card(
      color: theme.colorScheme.surface,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(20),
      // ),
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
            _buildInfoRow(theme, "Route", "$pickup - $drop"),
            _buildInfoRow(theme, "Departure Date", departureDate),
            _buildInfoRow(theme, "Departure Time", time),
            _buildInfoRow(theme, "Reserved Seats", seats.toString()),
            _buildInfoRow(theme, "Total Income", "Rs.${income.toStringAsFixed(2)}"),
            Divider(color: theme.dividerColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Completed Date & time",
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  completedDateTime!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInfoRow(ThemeData theme, String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      Text(value, style: theme.textTheme.bodyMedium),
    ],
  );
}
