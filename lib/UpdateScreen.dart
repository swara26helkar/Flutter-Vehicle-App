import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'PaymentScreen.dart'; // Ensure this file exists

class UpdateScreen extends StatefulWidget {
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  List<Map<String, dynamic>> entries = [];
  List<Map<String, dynamic>> filteredEntries = [];
  int selectedFera = 1;
  int totalAmount = 1200;
  int paidAmount = 0;
  String paymentMode = "Cash";
  File? _image;
  TextEditingController searchController = TextEditingController();
  TextEditingController vehicleController = TextEditingController();
  TextEditingController paidController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController pendingAmountController = TextEditingController();
  String selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    totalAmountController.text = totalAmount.toString();
    loadEntries();
  }

  Future<void> loadEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('entries');
    if (savedData != null) {
      setState(() {
        entries = List<Map<String, dynamic>>.from(json.decode(savedData));
        filterList(searchController.text);
      });
    }
  }

  Future<void> saveEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('entries', json.encode(entries));
  }

  void updateTotalPayment(int fera) {
    setState(() {
      totalAmount = fera * 1200;
      totalAmountController.text = totalAmount.toString();
    });
  }

  void updatePendingPayment() {
    setState(() {
      paidAmount = int.tryParse(paidController.text) ?? 0;
      pendingAmountController.text = (totalAmount - paidAmount).toString();
    });
  }

  Future<void> captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void showForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Daily Update Form",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: captureImage,
                  child: _image == null
                      ? Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[300],
                    child: Icon(Icons.camera_alt, size: 50),
                  )
                      : Image.file(_image!,
                      height: 100, width: 100, fit: BoxFit.cover),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: vehicleController,
                  maxLength: 6, // Prevents more than 6 digits
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Gadi Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedFera,
                  items: [1, 2, 3, 4].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFera = value!;
                      updateTotalPayment(selectedFera);
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Fera",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: totalAmountController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Total Payment",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: paymentMode,
                  items: ["Cash", "Online"].map((String mode) {
                    return DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      paymentMode = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Payment Mode",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: paidController,
                  keyboardType: TextInputType.number,
                  maxLength: 4, // Prevents more than 4 digits
                  decoration: InputDecoration(
                    labelText: "Paid Amount",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    updatePendingPayment();
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: pendingAmountController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Pending Payment",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Validation for all fields before submitting
                    if (vehicleController.text.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gadi Number must be 6 digits")));
                      return;
                    }
                    if (paidController.text.isEmpty ||
                        paidController.text.length > 4) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Paid Amount must be 1-4 digits")));
                      return;
                    }
                    if (_image == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please capture an image")));
                      return;
                    }
                    if (vehicleController.text.isEmpty ||
                        totalAmountController.text.isEmpty ||
                        paymentMode.isEmpty ||
                        paidController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("All fields are required")));
                      return;
                    }

                    String formattedDate = DateFormat('dd/MM/yyyy hh:mm a')
                        .format(DateTime.now());

                    setState(() {
                      entries.add({
                        "vehicle": vehicleController.text,
                        "fera": selectedFera,
                        "totalAmount": totalAmount,
                        "paidAmount": paidAmount,
                        "pendingAmount": totalAmount - paidAmount,
                        "paymentMode": paymentMode,
                        "image": _image?.path,
                        "dateTime": formattedDate,
                      });
                      saveEntries();
                      vehicleController.clear();
                      paidController.clear();
                      pendingAmountController.text = "";
                      _image = null;
                      searchController.clear();
                      filteredEntries = List.from(entries); // Reset filter
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void filterList(String query) {
    setState(() {
      filteredEntries = entries.where((entry) {
        String vehicle = entry["vehicle"].toString().toLowerCase();
        String entryDate = entry["dateTime"].split(' ')[0];
        return vehicle.contains(query.toLowerCase()) &&
            entryDate == selectedDate;
      }).toList();
    });
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
        filterList(searchController.text);
      });
    }
  }

  void navigateToPaymentActivity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(entries: filteredEntries),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Page", style: TextStyle(color: Colors.black,fontSize: 18),),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search by Gadi Number",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: filterList,
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.calendar_month_rounded, color: Colors.blue),
                  onPressed: () => pickDate(context),
                ),
                Text(
                  "Select Date",
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
          Text("Selected Date: $selectedDate",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: filteredEntries[index]["image"] != null
                        ? Image.file(
                        File(filteredEntries[index]["image"]), width: 100,
                        height: 100,
                        fit: BoxFit.cover)
                        : Icon(Icons.car_rental, size: 50),
                    title: Text(
                        "Gadi No.: ${filteredEntries[index]["vehicle"]}",
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fera: ${filteredEntries[index]["fera"]}",
                            style: TextStyle(fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text("Total: ₹${filteredEntries[index]["totalAmount"]}",
                            style: TextStyle(fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text("Paid: ₹${filteredEntries[index]["paidAmount"]}",
                            style: TextStyle(color: Colors.green)),
                        Text(
                            "Pending: ₹${filteredEntries[index]["pendingAmount"]}",
                            style: TextStyle(color: Colors.red)),
                        Text("Mode: ${filteredEntries[index]["paymentMode"]}",
                            style: TextStyle(fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        Text("Date: ${filteredEntries[index]["dateTime"]}",
                            style: TextStyle(fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: navigateToPaymentActivity,
              child: Text("Payment Status", style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(context),
        backgroundColor: Colors.pink,
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
