import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/models/booking_model.dart';
import 'package:shuttlemaster/providers/booking_provider.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/utils/formatters.dart';

class TravelingHistory extends StatefulWidget {
  final int initialIndex;

  const TravelingHistory({super.key, required this.initialIndex});

  @override
  State<TravelingHistory> createState() => _TravelingHistoryState();
}

class _TravelingHistoryState extends State<TravelingHistory> {
  final List<String> buttonLables = [
    'Upcoming',
    'Completed',
    'Cancelled',
    'Payable'
  ];
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final passengerId =
          Provider.of<UserProvider>(context, listen: false).user?.userId;

      if (passengerId != null) {
        Provider.of<BookingProvider>(context, listen: false)
            .fetchRideHistory(passengerId);
      } else {
        print("passenger Id not found");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomMainAppbar(title: 'Traveling History'),
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
                    return _buildActivity(buttonLables[index], index);
                  },
                ),
              ),
              Divider(
                color: Colors.black,
              ),
              Consumer<BookingProvider>(
                builder: (context, bookingsProvider, child) {
                  if (bookingsProvider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  //upcoming activities
                  if (_activeIndex == 0) {
                    final upcomingActivity = bookingsProvider.booking
                        .where((rideBooking) =>
                            rideBooking.status == 'Upcoming' && rideBooking is SingleRideBooking)
                        .toList();

                    if (upcomingActivity.isEmpty) {
                      return Center(child: Text('No upcoming activities.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: upcomingActivity.length,
                      itemBuilder: (context, index) {
                        final upcomingBooking = upcomingActivity[index] as SingleRideBooking;
                        final routeData = Provider.of<BookingProvider>(context).routeData;
                        final busNo = Provider.of<BookingProvider>(context).busNo;


                        return _buildTravelingUpcomingAndCancelledCard(
                          Formatters.formatDate(upcomingBooking.bookingDate), 
                          Formatters.formatTime(upcomingBooking.bookingDate),
                          busNo?[upcomingBooking.rideId] ?? 'N/A',
                          routeData?['pickup'] ?? 'N/A',
                          routeData?['drop'] ?? 'N/A',
                          upcomingBooking.amount,
                          upcomingBooking.isPaid,
                          upcomingBooking.paymentMethod,
                          '');
                      },
                    );
                  }

                  //completed activity
                  if (_activeIndex == 1) {
                    final completedActivity = bookingsProvider.booking
                        .where((rideBooking) =>
                            rideBooking.status == 'Completed' &&
                            rideBooking.isPaid == true && rideBooking is SingleRideBooking)
                        .toList();

                    if (completedActivity.isEmpty) {
                      return Center(child: Text('No completed activities.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: completedActivity.length,
                      itemBuilder: (context, index) {
                        final completedBooking = completedActivity[index] as SingleRideBooking;
                        
                        return _buildTravelingCompleteCard(
                            completedBooking.status,
                            Formatters.formatDate(completedBooking.bookingDate),
                            Formatters.formatTime(completedBooking.bookingDate),
                            completedBooking.amount,
                            completedBooking.paymentMethod);
                      },
                    );
                  }

                  //cancelled activity
                  if (_activeIndex == 2) {
                    final cancelledActivity = bookingsProvider.booking
                        .where((rideBooking) => rideBooking.status == 'Cancelled' && rideBooking is SingleRideBooking)
                        .toList();

                    final routeData = Provider.of<BookingProvider>(context).routeData;
                    final busNo = Provider.of<BookingProvider>(context).busNo;

                    if (cancelledActivity.isEmpty) {
                      return Center(child: Text('No cancelled activities.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: cancelledActivity.length,
                      itemBuilder: (context, index) {
                        final cancelledBooking = cancelledActivity[index] as SingleRideBooking;
                        
                        return _buildTravelingUpcomingAndCancelledCard(
                          Formatters.formatDate(cancelledBooking.bookingDate),
                          Formatters.formatTime(cancelledBooking.bookingDate),
                          busNo?['bus_no'] ?? 'N/A',
                          routeData?['pickup'] ?? 'N/A',
                          routeData?['drop'] ?? 'N/A',
                          cancelledBooking.amount,
                          cancelledBooking.isPaid,
                          cancelledBooking.paymentMethod,
                          '${Formatters.formatDate(cancelledBooking.cancelledDate!)}  ${Formatters.formatTime(cancelledBooking.cancelledDate!)}',
                        );
                      },
                    );
                  }

                  //payable section
                  if (_activeIndex == 3) {
                    final payableActivity = bookingsProvider.booking
                        .where((rideBooking) =>
                            rideBooking.status == 'Completed' &&
                            !rideBooking.isPaid && rideBooking is SingleRideBooking)
                        .toList();

                    if (payableActivity.isEmpty) {
                      return Center(child: Text('No payable activities.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: payableActivity.length,
                      itemBuilder: (context, index) {
                        final completedPayableBooking = payableActivity[index] as SingleRideBooking;
                        
                        return Column(
                          children: [
                            _buildTotalPayable(300.00),
                            Divider(
                              color: Colors.black,
                            ),
                            _buildTravelingCompleteCard(
                              completedPayableBooking.status,
                              Formatters.formatDate(completedPayableBooking.bookingDate),
                              Formatters.formatTime(completedPayableBooking.bookingDate),
                              completedPayableBooking.amount,
                              completedPayableBooking.paymentMethod
                            ,)
                          ],
                        );
                      },
                    );
                  }
                  return Center(child: Text('No activities.'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Upcoming, complete, cancel and payable button
  Widget _buildActivity(String butLabel, int index) {
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
          backgroundColor: MaterialStateProperty.all<Color>(
              isActive ? Colors.blueAccent : Colors.white),
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(color: Colors.blueAccent),
          ),
        ),
        child: Text(
          butLabel,
          style: TextStyle(color: isActive ? Colors.white : Colors.blueAccent),
        ),
      ),
    );
  }

  //Complete and payable section
  Widget _buildTravelingCompleteCard(String status, String date,String completedTime, double amount, String paymentMethod) {
    bool isCompleted = _activeIndex == 1;
    final routeData = Provider.of<BookingProvider>(context).routeData;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        child: Container(
          width: double.infinity,
          height: isCompleted ? 310 : 400,
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
                              color:Color.fromARGB(255, 28, 150, 34),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 20,
                                color:  Color.fromARGB(255, 28, 150, 34),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        Text(
                          date,
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Text(
                      completedTime,
                      style:TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bus No - 1080",
                      style:TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8),
                    _buildLocation(routeData?['pickup'] ?? 'N/A', 'Pickup'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: 2,
                        height: 40,
                        color: Colors.black,
                      ),
                    ),
                    _buildLocation(routeData?['drop'] ?? 'N/A', 'Drop'),
                    Divider(color: Colors.black),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Amount : Rs.${amount.toStringAsFixed(2)}",
                      style:TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _activeIndex == 3 ? "Not Paid" : "Paid",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _activeIndex == 3
                                  ? Colors.red
                                  : Colors.black),
                        ),
                        Text(
                          _activeIndex == 3 ? "" : "(By $paymentMethod)",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
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
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
                        ),
                        child: Text(
                         "pay",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocation(String location, String point) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.circle_outlined),
          SizedBox(
            width: 10,
          ),
          Text(
            '$point -  $location',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  //Upcoming & Cancellation section
  Widget _buildTravelingUpcomingAndCancelledCard(String scheduleDate,
      String time, String busNo,String pickup, String drop,  double amount,bool paymentStatus,String paymentMethod,String? cancellDateTime) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        child: Container(
          width: double.infinity,
          height: _activeIndex == 0 ? 330 : 250,
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
                        Icon(_activeIndex == 0 ? Icons.done : Icons.cancel, color: _activeIndex == 0 ? Colors.orangeAccent : Colors.black,),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          _activeIndex == 0 ? "Upcoming Booking" : "Cancelled Sucessfully",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: _activeIndex == 0 ? Colors.orangeAccent : Colors.black),
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
                      "Schedule Date",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      scheduleDate,
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
                      "Time",
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
                      "Bus No",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      busNo,
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
                      "Pickup",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pickup,
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
                      "Drop",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      drop,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Divider(color: Colors.black),
                _activeIndex == 0 ? 
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amount : Rs.${amount.toStringAsFixed(2)}",
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              paymentStatus == false ? "Not Paid" : "Paid",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: paymentStatus == false
                                      ? Colors.red
                                      : Colors.black),
                            ),
                            Text(
                              paymentStatus == false ? "" : "(By $paymentMethod)",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w800),
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
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.blueAccent),
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
                ) :
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cancellation Date & time",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cancellDateTime!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
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

  Widget _buildTotalPayable(double totalPayable) {
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
                        Icon(
                          Icons.payment,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Total Payable",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    "Rs.${totalPayable.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/total-payable');
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blueAccent),
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
