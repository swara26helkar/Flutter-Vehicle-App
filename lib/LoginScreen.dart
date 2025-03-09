import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Show OTP Popup
  void _showOtpPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:Colors.blue.shade100,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Enter OTP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          content: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "OTP",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text("Submit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,backgroundColor: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade500, Colors.blue.shade100], // Lighter gradient effect
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make scaffold transparent to show the gradient
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', width: 100, height: 100), // Logo
                SizedBox(height: 20),
                Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    style: TextStyle(color: Colors.black), // White text for input
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: Icon(Icons.phone, color: Colors.black),
                      counterText: "",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a mobile number';
                      } else if (!RegExp(r'^[6789]\d{9}$').hasMatch(value)) {
                        return 'Enter a valid 10-digit number starting with 6,7,8, or 9';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // White button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showOtpPopup();
                    }
                  },
                  child: Text("Send OTP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
