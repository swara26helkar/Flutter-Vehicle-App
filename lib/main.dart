import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vehiclerecord/firebase_options.dart';
import 'package:vehiclerecord/screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}
