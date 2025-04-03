import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shuttlemaster/components/custom_button.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';
import 'package:shuttlemaster/models/booking_model.dart';
import 'package:shuttlemaster/models/ride_model.dart';
import 'package:shuttlemaster/providers/booking_provider.dart';
import 'package:shuttlemaster/providers/user_provider.dart';
import 'package:shuttlemaster/services/booking_service.dart';
import 'package:shuttlemaster/services/ride_service.dart';
import 'package:shuttlemaster/utils/formatters.dart';
import 'package:shuttlemaster/utils/helpers.dart';

class TotalPayableScreen extends StatefulWidget {
  const TotalPayableScreen({super.key});

  @override
  State<TotalPayableScreen> createState() => _TotalPayableScreenState();
}

class _TotalPayableScreenState extends State<TotalPayableScreen> {
  List<bool> _isChecked = [];
  final List<String> _selectedbookingIds = [];
  double totalAmount = 0.0;
  final RideService _rideService = RideService();
  final BookingService _bookingService = BookingService();

  @override
  void initState() {
    super.initState();

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

  void _updateSelectedBookings(String bookingId, bool isChecked, double amount){
    setState(() {
      if(isChecked){
        if(!_selectedbookingIds.contains(bookingId)){
          _selectedbookingIds.add(bookingId);
          totalAmount += amount;
        } 
      }else{
        if(_selectedbookingIds.contains(bookingId)){
          _selectedbookingIds.remove(bookingId);
          totalAmount -= amount;
        }
      }
    });
  }

  void _showPaymentConfirmation(BuildContext context, List<String> bookingId) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text("Payment Confirmation", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          content: SizedBox(
            width: 300,
            child: Text(
              "Are you sure you want to confirm this payment?",
              style: theme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No", style: TextStyle(color: theme.colorScheme.primary))),
            TextButton(
              onPressed: () async {
                try{
                  for(final bookingId in _selectedbookingIds){
                    await _bookingService.updatePaymentState(bookingId);

                    BookingModel? booking = await _bookingService.getBookingById(bookingId);
                    String rideId = booking!.rideId;
                    String passengerId = booking.userId;

                    await _rideService.updateRidesPayments(rideId, passengerId,bookingId);

                    Helpers.showMessage(context, 'Your payment has been sucessfully completed');
                    Future.delayed(Duration(seconds: 1), () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, '/student/home');
                    });
                  }
                }catch (e){
                  Helpers.debugPrintWithBorder('Error: $e');
                }
              },
              child: Text("Yes", style: TextStyle(color: theme.colorScheme.primary))
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomMainAppbar(title: 'Total Payable', showLeading: true),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Payaments to be paid",
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),

                      Consumer<BookingProvider>(
                        builder: (context, bookingsProvider, child) {
                          if (bookingsProvider.isLoading) {
                            return Center(child: CircularProgressIndicator());
                          }

                          List<SingleRideBooking> filteredBookings = bookingsProvider.booking.where((rideBooking) => rideBooking.isPaid == false && rideBooking.status != 'Cancelled').whereType<SingleRideBooking>().toList();

                          filteredBookings.sort((a,b) => a.bookingDate.compareTo(b.bookingDate));

                          if(filteredBookings.isEmpty){
                            return Center(child: Text('No payable activities.'));
                          }

                          return FutureBuilder<Map<String, RideModel?>>(
                            future: _fetchAllRides(filteredBookings),
                            builder: (context, snapshot){
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error loading ride details'));
                              }

                              Map<String, RideModel?> rideData = snapshot.data ?? {};

                              if (_isChecked.length != filteredBookings.length) {
                                _isChecked = List.generate(filteredBookings.length, (index) => false);
                                totalAmount = 0.0; 
                                for (int i = 0; i < filteredBookings.length; i++) {
                                  if (_isChecked[i]) {
                                    totalAmount += filteredBookings[i].amount;
                                  }
                                }
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filteredBookings.length,
                                itemBuilder: (context, index){
                                  final booking = filteredBookings[index];
                                  final ride = rideData[booking.rideId];

                                  return  _buildSelectCard(
                                    index,
                                    ride!.route['pickup'] ?? 'N/A',
                                    ride.route['drop'] ?? 'N/A',
                                    Formatters.formatTime(ride.departureTime), 
                                    Formatters.formatTime(ride.completedTime!),
                                    Formatters.formatDate(booking.bookingDate),
                                    booking.amount,
                                    ride.status,
                                    booking.bookingId,
                                    theme
                                  );
                                }
                              );
                            }
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildAmountFooter(totalAmount, _selectedbookingIds, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectCard(int index,String pickup,String drop, String pickupTime, String dropTime, String date,double amount,String status,String bookingId, ThemeData theme) {
    return Card(
      child: Container(
        width: double.infinity,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Checkbox(
                    value: _isChecked[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked[index] = value!;
                        _updateSelectedBookings(bookingId, value, amount);
                      });
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "${Formatters.formatRoute(10, pickup)} - \n${Formatters.formatRoute(10, drop)} ",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    status == 'Completed' ? "$pickupTime - $dropTime" : pickupTime,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: theme.colorScheme.surface,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        date,
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Rs. ${amount.toStringAsFixed(2)}",
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

  Widget _buildAmountFooter(double total, List<String> selectedbookingIds, ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Divider(color: theme.dividerColor),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Total : ",
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 30,
                ),
                Text(
                  "Rs. ${total.toStringAsFixed(2)}",
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
            CustomButton(
              label: 'Pay Now', 
              onPressed: () {
                selectedbookingIds.isNotEmpty
                  ? () { 
                      for (var bookingId in selectedbookingIds) {
                        _showPaymentConfirmation(context, _selectedbookingIds);
                      }
                    }() 
                  : null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
