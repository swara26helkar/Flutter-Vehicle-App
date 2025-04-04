import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  final List<Map<String, dynamic>> cardData = [
    {"icon": Icons.car_crash, "title": "Total Daily Gadi", "subtitle": "20", "color": Colors.purple},
    {"icon": Icons.car_rental_sharp, "title": "Registered Gadi", "subtitle": "32", "color": Colors.blue},
    {"icon": Icons.money, "title": "Cash", "subtitle": "₹300000", "color": Colors.yellow},
    {"icon": Icons.payment, "title": "Online", "subtitle": "₹430000", "color": Colors.purple},
    {"icon": Icons.pending, "title": "Pending", "subtitle": "₹4999", "color": Colors.red},
    {"icon": Icons.paid, "title": "Paid Amount", "subtitle": "₹35000", "color": Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // New CardView with Text and Mobile Number
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.blue, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 40,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customer Support",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "+91 9876543210",
                        style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Daily Update Text
          Text(
            "Daily Update Data Of Gadi",
            style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          // Date Picker
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.calendar_today,
                  size: 24,
                  color: Colors.blue,
                ),
                SizedBox(width: 8),
                Text(
                  "Select Date",
                  style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Cards Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: cardData.length,
                itemBuilder: (context, index) {
                  final card = cardData[index];
                  return GestureDetector(
                    onTap: () {
                      print('Tapped on ${card["title"]}');
                    },
                    child: Card(
                      color: Colors.blue[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            card["icon"],
                            size: 48,
                            color: card["color"],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            card["title"],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            card["subtitle"],
                            style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
