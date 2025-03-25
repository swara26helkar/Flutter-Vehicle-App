import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'Dashboard.dart';
import 'NoInternetPage.dart';
import 'package:vehiclerecord/NoteUpdate.dart';
import 'UpdateScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> formDataList = [];
  List<Map<String, dynamic>> filteredDataList = [];
  TextEditingController searchController = TextEditingController();
  String selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Check for internet connectivity after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<ConnectivityResult> connectivityResults =
      await Connectivity().checkConnectivity();
      // Take the first result (or you can handle multiple results as needed)
      ConnectivityResult connectivityResult =
      connectivityResults.isNotEmpty ? connectivityResults.first : ConnectivityResult.none;
      if (connectivityResult == ConnectivityResult.none) {
        // Navigate to No Internet page if not connected
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NoInternetPage()),
        );
      }
    });
    filteredDataList = List.from(formDataList);
    searchController.addListener(_filterData);
  }



  void _filterData() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredDataList = formDataList.where((item) {
        String entryDate = item["dateTime"].split(' ')[0]; // Get entry date from item
        return (item['gadiNumber'].toLowerCase().contains(query) ||
            item['ownerName'].toLowerCase().contains(query) ||
            item['mobileNumber'].toLowerCase().contains(query)) &&
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
        _filterData();
      });
    }
  }
  void _shareOnWhatsApp(Map<String, dynamic> item) async {
    String phoneNumber = item['mobileNumber']; // Extract mobile number
    String countryCode = "+91"; // Change as needed (e.g., +1 for USA)
    String message = Uri.encodeComponent("""
🚗 *Vehicle Details* 🚗
🚘 *Gadi Number:* ${item['gadiNumber']}
👤 *Owner Name:* ${item['ownerName']}
📞 *Mobile:* ${item['mobileNumber']}
⚡ *Body Level:* ${item['bodyLevel']}
🚌 *Gadi Type:* ${item['gadiType']}
💰 *Payment:* ₹ ${item['payment']}
📅 *Date & Time:* ${item['dateTime']}
📅 *Image* ${item['image']}

  """);
    String url = "https://wa.me/$countryCode$phoneNumber?text=$message"+"Gadi Registered Successfully";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch WhatsApp");
    }
  }
  Future<void> _showPopupForm(BuildContext context, {int? editIndex}) async {
    File? selectedImage = editIndex != null
        ? formDataList[editIndex]['image']
        : null;
    TextEditingController gadiNumberController = TextEditingController(
        text: editIndex != null ? formDataList[editIndex]['gadiNumber'] : '');
    TextEditingController ownerNumberController = TextEditingController(
        text: editIndex != null ? formDataList[editIndex]['ownerName'] : '');
    TextEditingController mobileNumberController = TextEditingController(
        text: editIndex != null ? formDataList[editIndex]['mobileNumber'] : '');
    TextEditingController paymentController = TextEditingController(
        text: editIndex != null ? formDataList[editIndex]['payment'] : '');
    String dropdownValue1 = editIndex != null
        ? formDataList[editIndex]['bodyLevel']
        : '1';
    String dropdownValue2 = editIndex != null
        ? formDataList[editIndex]['gadiType']
        : 'Hyva';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                "Gadi Register Form",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(
                            source: ImageSource.camera);
                        if (pickedFile != null) {
                          final compressedImage = await FlutterImageCompress
                              .compressWithFile(
                            pickedFile.path,
                            quality: 85,
                          );

                          if (compressedImage != null) {
                            setDialogState(() {
                              selectedImage = File(pickedFile.path)
                                ..writeAsBytesSync(compressedImage);
                            });
                          }
                        }
                      },
                      child: Container(
                        height: 90,
                        width: 250,
                        margin: EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          image: selectedImage != null
                              ? DecorationImage(
                            image: FileImage(selectedImage!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: selectedImage == null
                            ? Icon(
                            Icons.camera_alt, size: 50, color: Colors.grey[700])
                            : null,
                      ),
                    ),
                    _buildTextField("Gadi Number", gadiNumberController, 10, TextInputType.text, Icons.directions_car),
                    _buildTextField("Owner Name", ownerNumberController, 30, TextInputType.text, Icons.person),
                    _buildTextField("Mobile Number", mobileNumberController, 10, TextInputType.number, Icons.phone),

                    _buildDropdown(
                        "Body Level", ['1', '2', '3', '4'], dropdownValue1, (newValue) {
                      setDialogState(() {
                        dropdownValue1 = newValue!;
                      });
                    }),
                    _buildDropdown(
                        "Gadi Type", ['Hyva', 'Other'], dropdownValue2, (newValue) {
                      setDialogState(() {
                        dropdownValue2 = newValue!;
                      });
                    }),
                    _buildTextField("payment", paymentController,4, TextInputType.number, Icons.payment),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          List<String> errors = [];

                          if (gadiNumberController.text.isEmpty) {
                            errors.add("Gadi Number is required");
                          }
                          if (ownerNumberController.text.isEmpty) {
                            errors.add("Owner Name is required");
                          }
                          if (mobileNumberController.text.isEmpty) {
                            errors.add("Mobile Number is required");
                          }
                          if (paymentController.text.isEmpty) {
                            errors.add("Payment is required");
                          }
                          if (selectedImage == null) {
                            errors.add("Image is required");
                          }
                          bool isDuplicate = formDataList.any((item) =>
                          item['gadiNumber'] == gadiNumberController.text &&
                              item['bodyLevel'] == dropdownValue1 &&
                              (editIndex == null || formDataList.indexOf(item) != editIndex)
                          );

                          if (isDuplicate) {
                            errors.add("Gadi with the same number and body level already exists");
                          }
                          if (errors.isNotEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Validation Errors"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: errors.map((e) => Text("• $e")).toList(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
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
                            if (editIndex == null) {
                              formDataList.add({
                                'image': selectedImage,
                                'gadiNumber': gadiNumberController.text,
                                'ownerName': ownerNumberController.text,
                                'mobileNumber': mobileNumberController.text,
                                'payment': paymentController.text,
                                'bodyLevel': dropdownValue1,
                                'gadiType': dropdownValue2,
                                "dateTime": formattedDate,
                              });
                            } else {
                              formDataList[editIndex] = {
                                'image': selectedImage,
                                'gadiNumber': gadiNumberController.text,
                                'ownerName': ownerNumberController.text,
                                'mobileNumber': mobileNumberController.text,
                                'payment': paymentController.text,
                                'bodyLevel': dropdownValue1,
                                'gadiType': dropdownValue2,
                                "dateTime": formattedDate,
                              };
                            }
                            _filterData();
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home", style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.bold),),
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
                    onChanged: (value) => _filterData(),
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
            child: filteredDataList.isEmpty
                ? Center(child: Text("No Data", style: TextStyle(fontSize: 20)))
                : ListView.builder(
              itemCount: filteredDataList.length,
              itemBuilder: (context, index) {
                final item = filteredDataList[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ListTile(
                        leading: item['image'] != null
                            ? GestureDetector(
                          onTap: () {
                            _showFullImage(context, item['image']);
                          },
                          child: Image.file(
                            item['image'],
                            width: 90,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(Icons.image, size: 50),
                        title: Row(
                          children: [
                            Icon(Icons.directions_car, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text(
                              "${item['gadiNumber']}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${item['ownerName']}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.phone, color: Colors.black),
                                SizedBox(width: 8),
                                Text(
                                  "${item['mobileNumber']}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.speed, color: Colors.lightBlue[200]),
                                SizedBox(width: 8),
                                Text(
                                  "Body Level: ${item['bodyLevel']}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[300],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.directions_bus, color: Colors.purple),
                                SizedBox(width: 8),
                                Text(
                                  "${item['gadiType']}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.payment, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  "₹ ${item['payment']}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.date_range, color: Colors.pink),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${item['dateTime']}",
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.pink),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _shareOnWhatsApp(item);
                              },
                              icon: Icon(Icons.share, color: Colors.white),
                              label: Text("Share" ,style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                _showPopupForm(context, editIndex: index);
                              },
                              icon: Icon(Icons.edit, color: Colors.white),
                              label: Text("Edit",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  formDataList.removeAt(index);
                                  _filterData();
                                });
                              },
                              icon: Icon(Icons.delete, color: Colors.white),
                              label: Text("Delete",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPopupForm(context),
        backgroundColor: Colors.pink,
        child: Icon(Icons.add, color: Colors.white,),
      ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Add this line
          backgroundColor: Colors.blue.shade400,
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateScreen()));
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NoteUpdate()));
            }
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard, color: Colors.white), label: "Dashboard"),
            BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.white), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.update, color: Colors.white), label: "Daily Update"),
            BottomNavigationBarItem(
                icon: Icon(Icons.note, color: Colors.white), label: "Note"),
          ],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: true,
        )
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, int maxLength, TextInputType keyboardType, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: Icon(icon, color: Colors.blue), // 👈 Left side icon
          counterText: "", // MaxLength counter ko hide karne ke liye
        ),
      ),
    );
  }


  Widget _buildDropdown(String label, List<String> items, String selectedValue,
      Function(String?) onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
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

