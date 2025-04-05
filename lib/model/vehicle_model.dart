class VehicleModel {
  String? id;
  String? ownerName;
  String? mobileNumber;
  double? payment;

  VehicleModel(this.id, this.ownerName, this.mobileNumber, this.payment);

  VehicleModel.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        ownerName = json["owner_name"],
        mobileNumber = json["mobile_number"],
        payment = json["payment"];

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'owner_name': ownerName,
      'mobile_number': mobileNumber,
      'payment': payment,
    };
  }

  @override
  String toString() {
    return 'VehicleModel{id: $id, ownerNumber: $ownerName, mobileNumber: $mobileNumber, payment: $payment}';
  }
}
