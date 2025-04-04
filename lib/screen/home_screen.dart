import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vehiclerecord/model/vehicle_model.dart';
import 'package:vehiclerecord/util/style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Style _style = Style();
  List<VehicleModel> vehicleList = [];
  User? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    FirebaseDatabase.instance
        .ref("app/${user!.uid}/vehicle_list")
        .onValue
        .listen((event) {
      vehicleList.add(VehicleModel(
        event.snapshot.child("info").child("id").value.toString(),
        event.snapshot.child("info").child("owner_name").value.toString(),
        event.snapshot.child("info").child("mobile_number").value.toString(),
        double.parse(
          event.snapshot.child("info").child("payment").value.toString(),
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: _style.getTTFInputDecoration(
                hintText: "Search",
                icon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(child: ListView.builder(
            itemBuilder: (context, index) {
              return Container();
            },
          )),
        ],
      ),
    );
  }
}
