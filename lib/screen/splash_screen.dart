import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vehiclerecord/screen/home_screen.dart';
import 'package:vehiclerecord/screen/btm_nav_screen.dart';
import 'package:vehiclerecord/screen/phone_auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    Future.delayed(Duration(seconds: 3), () {

    }).then((value) {
      if (_user != null) {
        print("USER ${_user.toString()}");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => BtmNavScreen(),
          ),
              (route) => false,
        );
      } else {
        print("USER ${_user.toString()}");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
              (route) => false,
        );
      }
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
