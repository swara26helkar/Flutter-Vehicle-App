import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vehiclerecord/model/vehicle_model.dart';
import 'package:vehiclerecord/util/style.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final Style _style = Style();

  TextEditingController vehicleNumberTEC = TextEditingController();
  TextEditingController ownerNameTEC = TextEditingController();
  TextEditingController mobileNumberTEC = TextEditingController();
  TextEditingController bodyLevelTEC = TextEditingController();
  TextEditingController vehicleTypeTEC = TextEditingController();
  TextEditingController paymentTEC = TextEditingController();

  List<int> _bodyLevelList = [1, 2, 3, 4];
  List<String> _vehicleTypeList = ["Hyva", "Other"];

  GlobalKey<FormState> vehicleFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Vehicle"),
      ),
      body: Form(
          key: vehicleFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autofocus: false,
                    validator: (value) => _validate(value),
                    controller: vehicleNumberTEC,
                    decoration: _style.getTTFInputDecoration(
                      hintText: "Vehicle Number",
                      icon: Icon(
                        Icons.directions_car,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.name,
                    validator: (value) => _validate(value),
                    controller: ownerNameTEC,
                    decoration: _style.getTTFInputDecoration(
                      hintText: "Owner Name",
                      icon: Icon(
                        Icons.account_circle_rounded,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.phone,
                    validator: (value) => _validate(value),
                    controller: mobileNumberTEC,
                    decoration: _style.getTTFInputDecoration(
                      hintText: "Mobile Number",
                      icon: Icon(
                        Icons.call_rounded,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autofocus: false,
                    validator: (value) => _validate(value),
                    controller: paymentTEC,
                    keyboardType: TextInputType.number,
                    decoration: _style.getTTFInputDecoration(
                      hintText: "Payment",
                      icon: Icon(
                        Icons.payment_rounded,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => _onAddButtonClicked(),
                    child: Text("Add"),
                  ),
                )
              ],
            ),
          )),
    );
  }

  _validate(String? textFieldValue) {
    if (textFieldValue == null || textFieldValue.isEmpty) {
      return "This field is required";
    } else {
      return null;
    }
  }

  _onAddButtonClicked() {
    if (vehicleFormKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Add Vehicle"),
          content: Text(
              "Are you sure you want to proceed with adding this vehicle?"),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("No"),
            ),
            OutlinedButton(
              onPressed: () {
                // todo: add vehicle to database
                Uuid uuid = Uuid();
                String id = uuid.v4();
                User? user = FirebaseAuth.instance.currentUser;

                VehicleModel vehicleModel = VehicleModel(id, ownerNameTEC.text,
                    mobileNumberTEC.text, double.parse(paymentTEC.text));

                // adding vehicle to database
                FirebaseDatabase.instance
                    .ref("app/${user!.uid}/vehicle_list/$id/info")
                    .set(vehicleModel.toJson())
                    .then(
                  (value) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Vehicle added"),
                      ),
                    );
                  },
                );
              },
              child: Text("Yes"),
            ),
          ],
        ),
      );
    }
  }
}
