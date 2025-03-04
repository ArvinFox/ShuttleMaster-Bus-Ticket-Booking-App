import 'package:flutter/material.dart';
import 'package:shuttlemaster/components/custom_main_appbar.dart';

class TravelingHistory extends StatefulWidget {
  final int initialIndex;

  const TravelingHistory({super.key, required this.initialIndex});

  @override
  State<TravelingHistory> createState() => _TravelingHistoryState();
}

class _TravelingHistoryState extends State<TravelingHistory> {
  final List<String> buttonLables = [
    'Ongoing',
    'Completed',
    'Cancelled',
    'Payable'
  ];
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;
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
              if (_activeIndex == 0)
                _buildTravelingCompleteCard(
                    "Ongoing", "25 Jan 2025", "18:00 PM", "NA 1090", 300)
              else if (_activeIndex == 1)
                _buildTravelingCompleteCard(
                    "Completed", "25 Jan 2025", "18:00 PM", "NA 1090", 300)
              else if (_activeIndex == 2)
                _buildTravelingCancelledCard("20 Jan 2025", "07:30 AM",
                    "Kadawatha", "NSBM", "27 Jan 2025 20:00 PM")
              else ...[
                _buildTotalPayable(300.00),
                Divider(
                  color: Colors.black,
                ),
                _buildTravelingCompleteCard(
                    "Completed", "25 Jan 2025", "18:00 PM", "NA 1090", 300),
              ]
            ],
          ),
        ),
      ),
    );
  }

  //Ongoing, complete, cancellet and payable button
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

  //Ongoing.complete and payable section
  Widget _buildTravelingCompleteCard(String status, String date,
      String completedTime, String busNo, double amount) {
    bool isCompleted = _activeIndex == 1;

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
                              color: _activeIndex == 0
                                  ? Colors.orangeAccent
                                  : Color.fromARGB(255, 28, 150, 34),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              status,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: _activeIndex == 0
                                      ? Colors.orangeAccent
                                      : Color.fromARGB(255, 28, 150, 34),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          date,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    Text(
                      completedTime,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bus No - $busNo",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8),
                    _buildLocation("Kadawatha 18:00 PM"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: 2,
                        height: 40,
                        color: Colors.black,
                      ),
                    ),
                    _buildLocation("NSBM 17:00 PM"),
                    Divider(color: Colors.black),
                  ],
                ),
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
                          _activeIndex == 3 ? "Not Paid" : "Paid",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _activeIndex == 3
                                  ? Colors.red
                                  : Colors.black),
                        ),
                        Text(
                          _activeIndex == 3 ? "" : "(By Cash)",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w800),
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
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.blueAccent),
                        ),
                        child: Text(
                          _activeIndex == 3 ? "Pay" : "Cancel Booking",
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

  //cancellation section
  Widget _buildTravelingCancelledCard(String scheduleDate, String time,
      String pickup, String drop, String cancellDateTime) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        child: Container(
          width: double.infinity,
          height: 250,
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
                        Icon(Icons.cancel),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Cancelled Sucessfully",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                Text(
                  "Cancellation Date & time",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  cancellDateTime,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
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
