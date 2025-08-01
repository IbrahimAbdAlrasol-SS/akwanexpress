// ignore: file_names
import 'package:Tosell/Features/shipments/models/Marchent.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';

class Shipment {
  String? code;
  int? type;
  int? status;
  int? ordersCount;
  int? receivedOrders;
  int? merchantsCount;
  int? deliveredOrders;
  int? priority;
  List<Order>? orders;
  // String? merchantName;
  Merchant? merchant;
  String? id;
  bool? deleted;
  String? creationDate;
  int? orderStatus;

  Shipment(
      {this.code,
      this.ordersCount,
      this.merchantsCount,
      this.merchant,
      this.type,
      this.status,
      this.deliveredOrders,
      this.receivedOrders,
      this.id,
      this.orders,
      this.priority,
      // this.merchantName,
      this.deleted,
      this.orderStatus,
      this.creationDate});

  Shipment.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    receivedOrders = json['receivedOrders'];
    deliveredOrders = json['deliveredOrders'];
    ordersCount = json['ordersCount'];
    merchantsCount = json['merchantsCount'];
    // merchantName = json['merchantName'];
    orderStatus = json['orderStatus'];
    json['merchant'] != null
        ? merchant = Merchant.fromJson(json['merchant'])
        : null;

    type = json['type'];
    if (json['orders'] != null) {
      orders = <Order>[];
      json['orders'].forEach((v) {
        orders!.add(new Order.fromJson(v));
      });
    }
    priority = json['priority'];
    status = json['status'];
    id = json['id'];
    deleted = json['deleted'];
    creationDate = json['creationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['ordersCount'] = this.ordersCount;
    data['orderStatus'] = this.orderStatus;
    data['type'] = this.type;
    data['priority'] = this.priority;
    data['status'] = this.status;
    data['id'] = this.id;
    data['deleted'] = this.deleted;
    data['creationDate'] = this.creationDate;
    data['merchantsCount'] = this.merchantsCount;
    return data;
  }
}
