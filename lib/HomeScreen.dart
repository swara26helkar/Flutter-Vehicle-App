import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'UpdateScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> formDataList = [];
  List<Map<String, dynamic>> filteredDataList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredDataList = List.from(formDataList);
    searchController.addListener(_filterData);
  }

  void _filterData() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredDataList = formDataList.where((item) {
        return item['gadiNumber'].toLowerCase().contains(query) ||
            item['ownerName'].toLowerCase().contains(query) ||
            item['mobileNumber'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _showPopupForm(BuildContext context, {int? editIndex}) async {
    File? selectedImage = editIndex != null ? formDataList[editIndex]['image'] : null;
    TextEditingController gadiNumberController = TextEditingController(text: editIndex != null ? formDataList[editIndex]['gadiNumber'] : '');
    TextEditingController ownerNumberController = TextEditingController(text: editIndex != null ? formDataList[editIndex]['ownerName'] : '');
    TextEditingController mobileNumberController = TextEditingController(text: editIndex != null ? formDataList[editIndex]['mobileNumber'] : '');
    String dropdownValue1 = editIndex != null ? formDataList[editIndex]['bodyLevel'] : '1';
    String dropdownValue2 = editIndex != null ? formDataList[editIndex]['gadiType'] : 'Hyva';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                "Gadi Register Form",
                style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                          setDialogState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: 150,
                        margin: EdgeInsets.only(bottom: 10),
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
                            ? Icon(Icons.camera_alt, size: 50, color: Colors.grey[700])
                            : null,
                      ),
                    ),
                    _buildTextField("Gadi Number", gadiNumberController, 6, TextInputType.text),
                    _buildTextField("Owner Name", ownerNumberController, 20, TextInputType.text),
                    _buildTextField("Mobile Number", mobileNumberController, 10, TextInputType.number),
                    _buildDropdown("Body Level", ['1', '2', '3', '4'], dropdownValue1, (newValue) {
                      setDialogState(() {
                        dropdownValue1 = newValue!;
                      });
                    }),
                    _buildDropdown("Gadi Type", ['Hyva', 'Other'], dropdownValue2, (newValue) {
                      setDialogState(() {
                        dropdownValue2 = newValue!;
                      });
                    }),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (gadiNumberController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gadi Number required"), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          if (ownerNumberController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Owner Name required"), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          if (mobileNumberController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Mobile Number required"), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          if (selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Image required"), backgroundColor: Colors.red),
                            );
                            return;
                          }

                          setState(() {
                            if (editIndex == null) {
                              formDataList.add({
                                'image': selectedImage,
                                'gadiNumber': gadiNumberController.text,
                                'ownerName': ownerNumberController.text,
                                'mobileNumber': mobileNumberController.text,
                                'bodyLevel': dropdownValue1,
                                'gadiType': dropdownValue2,
                              });
                            } else {
                              formDataList[editIndex] = {
                                'image': selectedImage,
                                'gadiNumber': gadiNumberController.text,
                                'ownerName': ownerNumberController.text,
                                'mobileNumber': mobileNumberController.text,
                                'bodyLevel': dropdownValue1,
                                'gadiType': dropdownValue2,
                              };
                            }
                            _filterData(); // Update filtered list
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
        title: Text("Home", style: TextStyle(color: Colors.black, fontSize: 18),),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search (Gadi Number, Owner, Mobile)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: filteredDataList.isEmpty
                ? Center(child: Text("No Data", style: TextStyle(fontSize: 20)))
                : ListView.builder(
              itemCount: filteredDataList.length,
              itemBuilder: (context, index) {
                final item = filteredDataList[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: item['image'] != null
                        ? Image.file(item['image'], width: 80, height: 80, fit: BoxFit.cover)
                        : Icon(Icons.image, size: 50),
                    title: Text("${item['gadiNumber']}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:Colors.redAccent),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${item['ownerName']}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:Colors.blue),),
                        Text("${item['mobileNumber']}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:Colors.black),),
                        Text("Body Level: ${item['bodyLevel']}",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color:Colors.lightBlue[200]),),
                        Text("Gadi Type: ${item['gadiType']}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color:Colors.purple),),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Prevents taking too much space
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showPopupForm(context, editIndex: index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              formDataList.removeAt(index);
                              _filterData();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPopupForm(context),
        backgroundColor: Colors.pink,
        child: Icon(Icons.add,color: Colors.white,),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade400,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateScreen()));
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.white), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.update, color: Colors.white), label: "Daily Update"),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, int maxLength, TextInputType keyboardType) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          counterText: "", // Hides the character counter
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue, Function(String?) onChanged) {
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
}
