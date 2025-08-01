import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:Tosell/Features/shipments/models/Marchent.dart';

class Order {
  String? code;
  String? customerName;
  String? customerPhoneNumber;
  Zone? pickupZone;
  Zone? deliveryZone;
  Location? pickupLocation;
  Location? deliveryLocation;
  int? status;
  String? content;
  bool? hasOtp;
  Merchant? merchant;
  String? pickupDelegateAssignedAt;
  String? pickedUpAt;
  dynamic totalAmount;
  int? size;
  bool? isPaid;
  int? priority;
  bool? partialDelivery;
  String? id;
  bool? deleted;
  String? creationDate;
  bool? isLast;

  Order(
      {this.code,
      this.customerName,
      this.customerPhoneNumber,
      this.pickupZone,
      this.deliveryZone,
      this.status,
      this.isLast,
      this.pickupLocation,
      this.deliveryLocation,
      this.content,
      this.merchant,
      this.pickupDelegateAssignedAt,
      this.pickedUpAt,
      this.totalAmount,
      this.size,
      this.isPaid,
      this.priority,
      this.partialDelivery,
      this.hasOtp,
      this.id,
      this.deleted,
      this.creationDate});

  Order.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    isLast = json['isLast'];
    customerName = json['customerName'];
    customerPhoneNumber = json['customerPhoneNumber'];
    pickupZone =
        json['pickUpZone'] != null ? Zone.fromJson(json['pickUpZone']) : null;
    deliveryZone = json['deliveryZone'] != null
        ? Zone.fromJson(json['deliveryZone'])
        : null;
    deliveryLocation = json['deliveryLocation'] != null
        ? Location.fromJson(json['deliveryLocation'])
        : null;

    pickupLocation = json['pickUpLocation'] != null
        ? Location.fromJson(json['pickUpLocation'])
        : null;
    merchant =
        json['merchant'] != null ? Merchant.fromJson(json['merchant']) : null;
    status = json['status'];
    hasOtp = json['hasOTP'];
    content = json['content'];
    pickupDelegateAssignedAt = json['pickupDelegateAssignedAt'];
    pickedUpAt = json['pickedUpAt'];
    totalAmount = json['totalAmount'];
    size = json['size'];
    isPaid = json['isPaid'];
    priority = json['priority'];
    partialDelivery = json['partialDelivery'];
    id = json['id'];
    deleted = json['deleted'];
    creationDate = json['creationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['customerName'] = this.customerName;
    data['customerPhoneNumber'] = this.customerPhoneNumber;
    if (this.pickupZone != null) {
      data['pickupZone'] = this.pickupZone!.toJson();
    }
    if (this.deliveryZone != null) {
      data['deliveryZone'] = this.deliveryZone!.toJson();
    }
    data['status'] = this.status;
    data['content'] = this.content;
    data['hasOTP'] = this.hasOtp;
    if (this.merchant != null) {
      data['merchant'] = this.merchant!.toJson();
    }
    data['pickupDelegateAssignedAt'] = this.pickupDelegateAssignedAt;
    data['pickedUpAt'] = this.pickedUpAt;
    data['totalAmount'] = this.totalAmount;
    data['size'] = this.size;
    data['isPaid'] = this.isPaid;
    data['priority'] = this.priority;
    data['partialDelivery'] = this.partialDelivery;
    data['id'] = this.id;
    data['deleted'] = this.deleted;
    data['creationDate'] = this.creationDate;
    return data;
  }
}
