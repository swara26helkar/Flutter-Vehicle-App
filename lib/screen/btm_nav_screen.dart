import 'package:flutter/material.dart';
import 'package:vehiclerecord/screen/Dashboard.dart';
import 'package:vehiclerecord/screen/NoteUpdate.dart';
import 'package:vehiclerecord/screen/UpdateScreen.dart';
import 'package:vehiclerecord/screen/home_screen.dart';

class BtmNavScreen extends StatefulWidget {
  const BtmNavScreen({super.key});

  @override
  State<BtmNavScreen> createState() => _BtmNavScreenState();
}

class _BtmNavScreenState extends State<BtmNavScreen> {
  int _selectedScreenIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        Dashboard(),
        HomeScreen(),
        UpdateScreen(),

        NoteUpdate(),
      ].elementAt(_selectedScreenIndex),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: ThemeData.light().primaryColor,
          type: BottomNavigationBarType.shifting,
          unselectedIconTheme:
              IconThemeData(color: ThemeData.light().unselectedWidgetColor),
          currentIndex: _selectedScreenIndex,
          onTap: (value) {
            setState(() {
              _selectedScreenIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.update_rounded),
              label: "Daily Update",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_add_rounded),
              label: "Note",
            )
          ]),
    );
  }
}
