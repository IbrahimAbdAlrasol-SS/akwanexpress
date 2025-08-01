import 'dart:async';
import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:Tosell/Features/auth/models/User.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';

class ShipmentInMap {
  User? merchant;
  String? id;
  String? code;
  Order? order;
  String? customerName;
  String? customerNumber;
  Location? pickUpLocation;
  Zone? pickUpZone;
  Location? deliveryLocation;
  Zone? deliveryZone;
  int? status;
  int? type;
  int? priority;
  bool? isOTP;
  String? merchantImg;
  String? merchantName;
  Location? pickUp;
  String? governorate;
  String? zone;
  bool? isPickup;
  int? shipmentStatus;

  ShipmentInMap({
    this.merchantImg,
    this.id,
    this.code,
    this.order,
    this.merchantName,
    this.pickUp,
    this.governorate,
    this.zone,
    this.priority,
    this.isPickup,
    this.isOTP,
    this.shipmentStatus,
    this.customerName,
    this.customerNumber,
    this.pickUpLocation,
    this.pickUpZone,
    this.deliveryZone,
    this.status,
    this.type,
    this.merchant,
    this.deliveryLocation,
  });

  ShipmentInMap.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    merchantImg = json['merchantImg'];
    code = json['code'];
    merchantName = json['merchantName'];
    pickUp = json['pickUp'] != null ? Location.fromJson(json['pickUp']) : null;
    deliveryLocation = json['deliveryLocation'] != null
        ? Location.fromJson(json['deliveryLocation'])
        : null;
    governorate = json['governorate'];
    zone = json['zone'];
    priority = json['priority'];
    isPickup = json['type'] == 0;
    isOTP = json['isOTP'];
    shipmentStatus = json['shipmentStatus'];
    customerName = json['customerName'];
    customerNumber = json['customerNumber'];
    pickUpLocation = json['pickUpLocation'] != null
        ? Location.fromJson(json['pickUpLocation'])
        : null;
    deliveryZone = json['deliveryZone'] != null
        ? Zone.fromJson(json['deliveryZone'])
        : null;
    merchant =
        json['merchant'] != null ? User.fromJson(json['merchant']) : null;
    pickUpZone =
        json['pickUpZone'] != null ? Zone.fromJson(json['pickUpZone']) : null;
    status = json['status'];
    type = json['type'];
  }
}

class Location {
  double? lat;
  double? long;

  Location({this.lat, this.long});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    long = json['long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['long'] = this.long;
    return data;
  }
}
