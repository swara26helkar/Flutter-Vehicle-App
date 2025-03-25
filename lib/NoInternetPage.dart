import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoInternetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("No Internet",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.signal_wifi_off,
              color: Colors.red,
              size: 120,
            ),
            SizedBox(height: 20),
            Text(
              "No Internet Connection.\nPlease check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color:Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}