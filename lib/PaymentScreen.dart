import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> entries;

  PaymentScreen({required this.entries});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<Map<String, dynamic>> cashPayments = [];
  List<Map<String, dynamic>> onlinePayments = [];
  List<Map<String, dynamic>> bothPayments = [];

  @override
  void initState() {
    super.initState();
    _saveToSharedPreferences(widget.entries);
    _loadFromSharedPreferences();
  }

  // Save Data to SharedPreferences
  Future<void> _saveToSharedPreferences(List<Map<String, dynamic>> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedData = jsonEncode(data);
    await prefs.setString('payment_data', encodedData);
  }

  // Load Data from SharedPreferences
  Future<void> _loadFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('payment_data');

    if (storedData != null) {
      List<dynamic> decodedData = jsonDecode(storedData);
      setState(() {
        List<Map<String, dynamic>> loadedEntries =
        decodedData.map((e) => Map<String, dynamic>.from(e)).toList();

        cashPayments =
            loadedEntries.where((entry) => entry["paymentMode"] == "Cash").toList();
        onlinePayments =
            loadedEntries.where((entry) => entry["paymentMode"] == "Online").toList();
        onlinePayments =
            loadedEntries.where((entry) => entry["paymentMode"] == "Both").toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title: Text("Payment Page",style: TextStyle(fontSize: 18,color:Colors.black,fontWeight: FontWeight.bold),),
            backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.black),
          bottom: TabBar(
            labelStyle: TextStyle(fontSize: 12, color: Colors.white,fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Cash Payments"),
              Tab(text: "Online Payments"),
              Tab(text: "Both Payments"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PaymentList(payments: cashPayments),
            PaymentList(payments: onlinePayments),
            PaymentList(payments: bothPayments),
          ],
        ),
      ),
    );
  }
}

class PaymentList extends StatelessWidget {
  final List<Map<String, dynamic>> payments;

  PaymentList({required this.payments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: payments[index]["image"] != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.file(
                File(payments[index]["image"]),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
                : Icon(Icons.car_rental, size: 50, color: Colors.blue),
            title: Text(
              "Vehicle: ${payments[index]["vehicle"]}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Fera: ${payments[index]["fera"]}"),
                Text("Body Level: ${payments[index]["bodylevel"]}"),
                Text("Total: ₹${payments[index]["totalAmount"]}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Paid: ₹${payments[index]["paidAmount"]}",
                    style: TextStyle(color: Colors.green)),
                Text("Cash Paid: ₹${payments[index]["cashAmount"]}",
                    style: TextStyle(color: Colors.green)),
                Text("Online Paid: ₹${payments[index]["onlineAmount"]}",
                    style: TextStyle(color: Colors.green)),
                Text("Pending: ₹${payments[index]["pendingAmount"]}",
                    style: TextStyle(color: Colors.red)),
                Text("Mode: ${payments[index]["paymentMode"]}"),
                Text(
                  "Date: ${payments[index]["dateTime"]}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
