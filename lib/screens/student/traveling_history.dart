import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/models/booking_model.dart';
import 'package:shuttlemaster/models/ride_model.dart';
import 'package:shuttlemaster/providers/booking_provider.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/services/booking_service.dart';
import 'package:shuttlemaster/services/ride_service.dart';
import 'package:shuttlemaster/utils/formatters.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class TravelingHistory extends StatefulWidget {
  final int initialIndex;

  const TravelingHistory({super.key, required this.initialIndex});

  @override
  State<TravelingHistory> createState() => _TravelingHistoryState();
}

class _TravelingHistoryState extends State<TravelingHistory> {
  final List<String> buttonLabels = ['Upcoming','Completed','Cancelled','Payable'];
  final BookingService _bookingService = BookingService();
  final RideService _rideService = RideService();
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final passengerId = Provider.of<UserProvider>(context, listen: false).user?.userId;

      if (passengerId != null) {
        Provider.of<BookingProvider>(context, listen: false).fetchRideHistory(passengerId);
      } else {
        print("passenger Id not found");
      }
    });
  }

  Future<Map<String, RideModel?>> _fetchAllRides(List<SingleRideBooking> bookings) async {
    Map<String, RideModel?> rideMap = {};
    List<Future<void>> fetchTasks = [];

    for (var booking in bookings) {
      fetchTasks.add(
        _rideService.getRideById(booking.rideId).then((ride) {
          rideMap[booking.rideId] = ride;
        }),
      );
    }

    await Future.wait(fetchTasks);
    return rideMap;
  }

  void _showConfirmationDialog(
    BuildContext context,
    String bookingId,
    String title,
    String content,
    Future<void> Function(String bookingId) onConfirm,
    String successMessage,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 300,
            child: Text(
              content,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No", style: TextStyle(color: theme.colorScheme.primary)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await onConfirm(bookingId);
                  Helpers.showMessage(context, successMessage);
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/student/home');
                  });
                } catch (e) {
                  Helpers.debugPrintWithBorder('Error: $e');
                }
              },
              child: Text("Yes", style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showCancelConfirmation(BuildContext context, String bookingId) {
    _showConfirmationDialog(
      context,
      bookingId,
      "Cancel Booking",
      "Are you sure you want to cancel this booking?",
      (String bookingId) async {
        await _bookingService.updateState(bookingId);
        BookingModel? booking = await _bookingService.getBookingById(bookingId);
        String rideId = booking!.rideId;
        String passengerId = booking.userId;
        await _rideService.updateRidesOnCancellation(rideId, passengerId);
      },
      'Booking cancelled successfully.',
    );
  }

  void _showPaymentConfirmation(BuildContext context, String bookingId) {
    _showConfirmationDialog(
      context,
      bookingId,
      "Payment Confirmation",
      "Are you sure you want to confirm this payment?",
      (String bookingId) async {
        await _bookingService.updatePaymentState(bookingId);
        BookingModel? booking = await _bookingService.getBookingById(bookingId);
        String rideId = booking!.rideId;
        String passengerId = booking.userId;
        await _rideService.updateRidesPayments(rideId, passengerId, bookingId);
      },
      'Your payment has been successfully completed.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomMainAppbar(title: 'Traveling History', showLeading: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildActivity(buttonLabels[index], index, theme);
                  },
                ),
              ),
              Divider(color: theme.dividerColor),
              Consumer<BookingProvider>(
                builder: (context, bookingsProvider, child) {
                  if (bookingsProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<SingleRideBooking> filteredBookings = bookingsProvider.booking
                    .where((rideBooking) {
                      switch (_activeIndex) {
                        case 0: return rideBooking.status == 'Upcoming';
                        case 1: return rideBooking.status == 'Completed';
                        case 2: return rideBooking.status == 'Cancelled';
                        case 3: return rideBooking.isPaid == false && rideBooking.status != 'Cancelled';
                        default: return false;
                      }
                    })
                    .whereType<SingleRideBooking>()
                    .toList();
                  
                  if (filteredBookings.isEmpty) {
                    if (_activeIndex == 0) {
                      return Center(child: Text('No upcoming activities.'));
                    } else if (_activeIndex == 1) {
                      return Center(child: Text('No completed activities.'));
                    } else if (_activeIndex == 2) {
                      return Center(child: Text('No cancelled activities.'));
                    } else if (_activeIndex == 3) {
                      return Center(child: Text('No payable activities.'));
                    } else {
                      return Center(child: Text('No activities.'));
                    }
                  }

                  return FutureBuilder<Map<String, RideModel?>>(
                    future: _fetchAllRides(filteredBookings),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading ride details'));
                      }

                      Map<String, RideModel?> rideData = snapshot.data ?? {};

                      double totalPayableAmount = 0.0;
                      for (final booking in filteredBookings) {
                        final singleBooking = booking;
                        totalPayableAmount += singleBooking.amount;
                      }
                      
                      if (_activeIndex == 3) {
                        return Column(
                          children: [
                            _buildTotalPayable(totalPayableAmount, theme),
                            Divider(color: theme.dividerColor),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: filteredBookings.length,
                              itemBuilder: (context, index) {
                                final booking = filteredBookings[index];
                                final ride = rideData[booking.rideId];

                                if (ride?.completedTime != null) {
                                  return _buildTravelingCompleteCard(
                                    booking.status,
                                    Formatters.formatDate(booking.bookingDate),
                                    Formatters.formatTime(ride!.completedTime!),
                                    booking.amount,
                                    booking.paymentMethod,
                                    ride.busNo,
                                    ride.route['pickup'] ?? 'N/A',
                                    Formatters.formatTime(ride.departureTime),
                                    ride.route['drop'] ?? 'N/A',
                                    booking.isPaid,
                                    booking.bookingId,
                                    theme,
                                  );
                                } else {
                                  return _buildTravelingUpcomingAndCancelledCard(
                                    Formatters.formatDate(booking.bookingDate),
                                    Formatters.formatTime(ride!.departureTime),
                                    ride.busNo,
                                    ride.route['pickup'] ?? 'N/A',
                                    ride.route['drop'] ?? 'N/A',
                                    booking.amount,
                                    booking.isPaid,
                                    booking.paymentMethod,
                                    _activeIndex == 2
                                      ? (booking.cancelledDate != null
                                        ? '${Formatters.formatDate(booking.cancelledDate!)}  ${Formatters.formatTime(booking.cancelledDate!)}'
                                        : 'N/A')
                                      : '',
                                    booking.bookingId,
                                    theme,
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          final ride = rideData[booking.rideId];

                          if (_activeIndex == 1 || _activeIndex == 3) {
                            return _buildTravelingCompleteCard(
                              booking.status,
                              Formatters.formatDate(booking.bookingDate),
                              Formatters.formatTime(ride!.completedTime!),
                              booking.amount,
                              booking.paymentMethod,
                              ride.busNo,
                              ride.route['pickup'] ?? 'N/A',
                              Formatters.formatTime(ride.departureTime),
                              ride.route['drop'] ?? 'N/A',
                              booking.isPaid,
                              booking.bookingId,
                              theme,
                            );
                          } else {
                            return _buildTravelingUpcomingAndCancelledCard(
                              Formatters.formatDate(booking.bookingDate),
                              Formatters.formatTime(ride!.departureTime),
                              ride.busNo,
                              ride.route['pickup'] ?? 'N/A',
                              ride.route['drop'] ?? 'N/A',
                              booking.amount,
                              booking.isPaid,
                              booking.paymentMethod,
                              _activeIndex == 2
                                ? (booking.cancelledDate != null
                                  ? '${Formatters.formatDate(booking.cancelledDate!)}  ${Formatters.formatTime(booking.cancelledDate!)}'
                                  : 'N/A')
                                : '',
                              booking.bookingId,
                              theme,
                            );
                          }
                        }
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Upcoming, complete, cancel and payable button
  Widget _buildActivity(String butLabel, int index, ThemeData theme) {
    bool isActive = _activeIndex == index;

    return Padding(
      padding: EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _activeIndex = index;
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (states) => isActive
            ? theme.colorScheme.primary
            : theme.scaffoldBackgroundColor,
          ),
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(color: theme.colorScheme.primary),
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) => isActive
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
          ),
        ),
        child: Text(
          butLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  //Complete and payable section
  Widget _buildTravelingCompleteCard(String status, String date,String completedTime, double amount, String paymentMethod, String busNo,String pickup, String pickupTime, String drop,bool paymentStatus,String bookingId, ThemeData theme) {
  bool isCompleted = _activeIndex == 1;

  Color cardColor = theme.colorScheme.surface;
  Color textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
  Color paidColor = theme.colorScheme.onPrimary;
  Color unpaidColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: status == "Upcoming"
                              ? Colors.orange
                              : Color.fromARGB(255, 28, 150, 34),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 20,
                              color: status == "Upcoming"
                                ? Colors.orange
                                : Color.fromARGB(255, 28, 150, 34),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      Text(
                        date,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Text(
                    status == "Upcoming" ? '' : completedTime,
                    style:theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bus No - $busNo",
                    style:theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(Icons.circle_outlined, color: textColor,),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '$pickup  $pickupTime',
                          style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: 2,
                      height: 40,
                      color: textColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(Icons.circle_outlined, color: textColor,),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '$drop  ${status == "Upcoming" ? '' : completedTime}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: theme.dividerColor),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Amount : Rs.${amount.toStringAsFixed(2)}",
                    style:theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        paymentStatus == false ? "Not Paid" : "Paid",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: paymentStatus ? paidColor : unpaidColor,),
                      ),
                      Text(
                        paymentStatus == false ? "" : "(By $paymentMethod)",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
              if (!isCompleted || _activeIndex == 3)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_activeIndex == 3) {
                          //payment action
                          _showPaymentConfirmation(context, bookingId);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>( Colors.blueAccent),
                      ),
                      child: Text(
                        "Pay",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  //Upcoming & Cancellation section
  Widget _buildTravelingUpcomingAndCancelledCard(String scheduleDate,String time,String busNo,String pickup,String drop,double amount, bool paymentStatus, String paymentMethod, String? cancellDateTime,String bookingId, ThemeData theme) {
    bool isUpcoming = _activeIndex == 0;
    Color? statusColor = isUpcoming ? Colors.orangeAccent : theme.textTheme.bodyLarge?.color;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        color: theme.colorScheme.surface,
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
                        isUpcoming ? Icons.event : Icons.cancel,
                        color: statusColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        isUpcoming ? "Upcoming Booking" : "Cancelled Successfully",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),

              _buildDetailRow("Schedule Date", scheduleDate, theme),
              _buildDetailRow("Time", time, theme),
              _buildDetailRow("Bus No", busNo, theme),
              _buildDetailRow("Pickup", pickup, theme),
              _buildDetailRow("Drop", drop, theme),

              Divider(color: theme.dividerColor),
              isUpcoming
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Amount : Rs.${amount.toStringAsFixed(2)}",
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                paymentStatus == false
                                  ? "Not Paid"
                                  : "Paid",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: paymentStatus == false
                                    ? Colors.red
                                    : theme.textTheme.bodyLarge?.color
                                ),
                              ),
                              Text(
                                paymentStatus == false
                                  ? ""
                                  : "(By $paymentMethod)",
                                style: TextStyle(fontSize: 12,fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: ElevatedButton(
                              onPressed: () {
                                //cancell booking
                                _showCancelConfirmation(context,bookingId);
                              },
                              style: ButtonStyle(
                                backgroundColor:MaterialStateProperty.all<Color>( Colors.blueAccent),
                              ),
                              child: Text(
                                "Cancel Booking",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cancellation Date & time",
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        cancellDateTime!,
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

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildTotalPayable(double totalPayable, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        child: Container(
          width: double.infinity,
          height: 180,
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
                        Icon(Icons.payment,color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          "Total Payable",
                          style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    "Rs.${totalPayable.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/total-payable');
                      },
                      style: ButtonStyle(
                        backgroundColor:MaterialStateProperty.all<Color>(Colors.blueAccent),
                      ),
                      child: Text(
                        "Pay Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}