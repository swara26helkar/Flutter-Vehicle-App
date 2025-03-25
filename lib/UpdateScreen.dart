import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'NoInternetPage.dart';
import 'PaymentScreen.dart'; // Ensure this file exists

class UpdateScreen extends StatefulWidget {
  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}
class _UpdateScreenState extends State<UpdateScreen> {
  List<Map<String, dynamic>> entries = [];
  List<Map<String, dynamic>> filteredEntries = [];
  int selectedFera = 1;
  String paymentMode = "Cash";
  double totalAmount = 0.0;
  double paidAmount = 0.0;
  double cashAmount = 0.0;
  double onlineAmount = 0.0;
  File? _image;
  TextEditingController searchController = TextEditingController();
  TextEditingController vehicleController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController paidController = TextEditingController();
  TextEditingController cashAmountController = TextEditingController();
  TextEditingController onlineAmountController = TextEditingController();
  TextEditingController pendingAmountController = TextEditingController();
  TextEditingController bodyLevelController = TextEditingController();
  String selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();

    // Connectivity check: Ensure that an internet connection is available.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<ConnectivityResult> connectivityResults =
      await Connectivity().checkConnectivity();
      ConnectivityResult connectivityResult = connectivityResults.isNotEmpty
          ? connectivityResults.first
          : ConnectivityResult.none;
      if (connectivityResult == ConnectivityResult.none) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NoInternetPage()),
        );
      }
    });

    // Add listeners for payment controllers to update pending payment.
    totalAmountController.addListener(updatePendingPayment);
    cashAmountController.addListener(updatePendingPayment);
    onlineAmountController.addListener(updatePendingPayment);
    paidController.addListener(updatePendingPayment);

    // Initialize the body level controller.
    bodyLevelController = TextEditingController();
  }

  void updatePendingPayment() {
    double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
    double paidAmount = 0.0;
    if (paymentMode == "Both") {
      double cashAmount = double.tryParse(cashAmountController.text) ?? 0.0;
      double onlineAmount = double.tryParse(onlineAmountController.text) ?? 0.0;
      paidAmount = cashAmount + onlineAmount;
    } else {
      paidAmount = double.tryParse(paidController.text) ?? 0.0;
    }
    double pendingAmount = totalAmount - paidAmount;
    pendingAmountController.text = pendingAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    totalAmountController.dispose();
    paidController.dispose();
    cashAmountController.dispose();
    onlineAmountController.dispose();
    pendingAmountController.dispose();
    super.dispose();
  }

  Future<void> captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final File? compressedImage = await compressImage(pickedFile);
      if (compressedImage != null) {
        setState(() {
          _image = compressedImage;
        });
      }
    }
  }
  Future<File?> compressImage(XFile xfile) async {
    try {
      // Load the image from the file
      final bytes = await xfile.readAsBytes();
      img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

      if (image == null) {
        print('Error: Unable to decode image');
        return null;
      }

      // Resize image (Optional: Adjust this as per your requirements)
      img.Image resized = img.copyResize(image, width: 1080, height: 720);

      // Compress the image
      List<int> compressedImage = img.encodeJpg(resized, quality: 85); // Quality parameter (0-100)

      // Save the compressed image to the file system
      final String outPath = "${xfile.path.substring(0, xfile.path.lastIndexOf('.'))}_compressed.jpg";
      File compressedFile = File(outPath)..writeAsBytesSync(compressedImage);

      print('Compressed image size: ${compressedFile.lengthSync()} bytes');
      return compressedFile; // Return the compressed file
    } catch (e) {
      print('Error compressing image: $e');
      return null;
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
                    width: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.camera_alt, size: 50),
                  )
                      : Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: vehicleController,
                  maxLength: 10,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Gadi Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car, color: Colors.blue),
                    counterText: '', // Hides the character counter
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedFera,
                  items: List.generate(10, (index) => index + 1).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFera = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Fera",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: bodyLevelController,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: InputDecoration(
                    labelText: "Body Level",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.build, color: Colors.blue),
                    counterText: '', // Hides the character counter
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: totalAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Total Payment",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.payment, color: Colors.blue),
                    counterText: '', // Hides the character counter
                  ),
                  onChanged: (value) {
                    updatePendingPayment();
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: paymentMode,
                  items: ["Cash", "Online", "Both"].map((String mode) {
                    return DropdownMenuItem<String>(
                      value: mode,
                      child: Text(mode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      paymentMode = value!;
                      updatePendingPayment();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Payment Mode",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                if (paymentMode == "Both") ...[
                  TextField(
                    controller: cashAmountController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: "Cash Amount",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                      counterText: '', // Hides the character counter
                    ),
                    onChanged: (value) {
                      updatePendingPayment();
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: onlineAmountController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: "Online Amount",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.online_prediction, color: Colors.green),
                      counterText: '', // Hides the character counter
                    ),
                    onChanged: (value) {
                      updatePendingPayment();
                    },
                  ),
                ] else ...[
                  TextField(
                    controller: paidController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: "Paid Amount",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.check_circle, color: Colors.green),
                      counterText: '', // Hides the character counter
                    ),
                    onChanged: (value) {
                      updatePendingPayment();
                    },
                  ),
                ],
                SizedBox(height: 16),
                TextField(
                  controller: pendingAmountController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Pending Payment",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warning, color: Colors.red),
                    counterText: '', // Hides the character counter
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    String errorMessage = "";
                    if (vehicleController.text.length != 10) {
                      errorMessage = "Gadi Number must be 10 characters.\n";
                    }
                    if (paymentMode == "Both") {
                      if (cashAmountController.text.isEmpty || onlineAmountController.text.isEmpty) {
                        errorMessage += "Both Cash and Online Amounts are required.\n";
                      }
                    } else {
                      if (paidController.text.isEmpty) {
                        errorMessage += "Paid Amount is required.\n";
                      }
                    }
                    if (totalAmountController.text.isEmpty) {
                      errorMessage += "Total Payment is required.\n";
                    }
                    if (_image == null) {
                      errorMessage += "Please capture an image.\n";
                    }
                    if (errorMessage.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Validation Error"),
                            content: Text(errorMessage),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    String formattedDate = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
                    setState(() {
                      entries.add({
                        "vehicle": vehicleController.text,
                        "fera": selectedFera,
                        "totalAmount": totalAmountController.text,
                        "paidAmount": paidController.text,
                        "bodylevel": bodyLevelController.text,
                        "cashAmount": cashAmountController.text,
                        "onlineAmount": onlineAmountController.text,
                        "pendingAmount":  pendingAmountController.text,
                        "paymentMode": paymentMode,
                        "image": _image?.path,
                        "dateTime": formattedDate,
                      });
                      vehicleController.clear();
                      bodyLevelController.clear();
                      paidController.clear();
                      paymentMode = 'Cash'; // Default value
                      selectedFera = 1;
                      totalAmountController.clear();
                      cashAmountController.clear();
                      onlineAmountController.clear();
                      pendingAmountController.text = "";
                      _image = null;
                      searchController.clear();
                      filteredEntries = List.from(entries);
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
  Future<void> shareEntry(Map<String, dynamic> entry) async {
    String vehicle = entry["vehicle"];
    int fera = double.tryParse(entry["fera"].toString())?.toInt() ?? 0;
    int totalAmount = double.tryParse(entry["totalAmount"].toString())?.toInt() ?? 0;
    int paidAmount = double.tryParse(entry["paidAmount"].toString())?.toInt() ?? 0;
    int pendingAmount = double.tryParse(entry["pendingAmount"].toString())?.toInt() ?? 0;
    int cashAmount = double.tryParse(entry["cashAmount"].toString())?.toInt() ?? 0;
    int onlineAmount = double.tryParse(entry["onlineAmount"].toString())?.toInt() ?? 0;
    int bodyLevel = double.tryParse(entry["bodylevel"].toString())?.toInt() ?? 0;
    String dateTime = entry["dateTime"];
    String? imagePath = entry["image"];
    String paymentMode = entry["paymentMode"] ?? "Unknown"; // Ensure paymentMode is defined

    // 🔹 Build payment details string with BOLD text
    String paymentDetails;
    if (paymentMode.toLowerCase() == 'both') {
      paymentDetails = '''
💵 *Cash Amount:* ₹$cashAmount  
🌐 *Online Amount:* ₹$onlineAmount''';
    } else {
      paymentDetails = '*Paid Amount:* ₹$paidAmount';
    }

    // 🔹 Build the message string with WhatsApp Bold Formatting
    String message = '''
🚗 *Vehicle Details* 🚗  
🚘 *Gadi No.:* $vehicle  
🔄 *Fera:* $fera  
⚡ *Body Level:* $bodyLevel  
💰 *Total Amount:* *₹$totalAmount*  
📜 *Payment Details:*  
$paymentDetails  
🕰️ *Pending Amount:* *₹$pendingAmount*  
💳 *Payment Mode:* $paymentMode  
📅 *Date:* $dateTime  
''';

    List<XFile> files = [];
    if (imagePath != null) {
      files.add(XFile(imagePath));
    }

    await Share.shareXFiles(
      files,
      text: message,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Page", style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),),
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
                      labelText: "Search (Gadi Number, Owner, Mobile)",
                      labelStyle: TextStyle(
                        fontSize: 18, // Adjust the label text size
                        color: Colors.blue, // Set the label text color
                        fontWeight: FontWeight.bold, // Make the label text bold
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.blue, size: 25),
                    ),
                    style: TextStyle(
                      color: Colors.black, // Set input text color
                      fontWeight: FontWeight.bold, // Make input text bold
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
                  style: TextStyle(fontSize: 16, color: Colors.blue,fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text("Selected Date: $selectedDate",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: filteredEntries.isEmpty
                ? Center(
              child: Text(
                "No Data",
                style: TextStyle(fontSize: 20),
              ),
            )
                : ListView.builder(
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: filteredEntries[index]["image"] != null
                            ? GestureDetector(
                          onTap: () {
                            _showFullImage(context, File(filteredEntries[index]["image"]));
                          },
                          child: Image.file(
                            File(filteredEntries[index]["image"]),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(Icons.car_rental, size: 50),
                        title: Row(
                          children: [
                            Icon(Icons.car_rental_outlined, color: Colors.red),
                            SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                "Gadi No: ${filteredEntries[index]["vehicle"]}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.directions_car, color: Colors.blue),
                                SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    "Fera: ${filteredEntries[index]["fera"]}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.directions_car, color: Colors.pink),
                                SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    "Body Level: ${filteredEntries[index]["bodylevel"]}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.attach_money, color: Colors.black),
                                SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    "Total: ₹${filteredEntries[index]["totalAmount"]}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Builder(
                              builder: (context) {
                                String mode = filteredEntries[index]["paymentMode"];
                                if (mode == "Both") {
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Cash Paid: ₹${filteredEntries[index]["cashAmount"]}",
                                              style: TextStyle(color: Colors.green),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "Online Paid: ₹${filteredEntries[index]["onlineAmount"]}",
                                              style: TextStyle(color: Colors.green),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Paid: ₹${filteredEntries[index]["paidAmount"]}",
                                          style: TextStyle(color: Colors.green),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Pending: ₹${filteredEntries[index]["pendingAmount"]}",
                                    style: TextStyle(color: Colors.red),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.payment, color: Colors.black),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Mode: ${filteredEntries[index]["paymentMode"]}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.date_range, color: Colors.purple),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${filteredEntries[index]["dateTime"].split(' ')[0]}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple),
                                    ),
                                    Text(
                                      "${filteredEntries[index]["dateTime"].split(' ')[1]}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.purple,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Share and Location buttons placed at the bottom of the Card
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => shareEntry(filteredEntries[index]),
                              icon: Icon(Icons.share, color: Colors.white),
                              label: Text("Share",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => shareEntry(filteredEntries[index]),
                              icon: Icon(Icons.location_on, color: Colors.white),
                              label: Text("Location",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
  void _showFullImage(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Container(
              width: MediaQuery.of(context).size.width * 1.0, // 90% of screen width
              height: MediaQuery.of(context).size.height * 0.2, // 80% of screen height
              child: Image.file(imageFile, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
