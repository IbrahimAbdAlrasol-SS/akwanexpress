import 'package:Tosell/Features/order/screens/order_details_screen.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class Notifications {
  String? notifyId;
  String? title;
  String? description;
  String? picture;
  String? notifyFor;
  String? helperId;
  int? type;
  String? date;
  String? userId;
  bool? isRead;
  String? createdAt;
  bool? deleted;
  String? id;
  String? creationDate;

  Notifications(
      {this.notifyId,
      this.title,
      this.description,
      this.picture,
      this.notifyFor,
      this.helperId,
      this.type,
      this.date,
      this.userId,
      this.isRead,
      this.createdAt,
      this.deleted,
      this.id,
      this.creationDate});

  Notifications.fromJson(Map<String, dynamic> json) {
    notifyId = json['notifyId'];
    title = json['title'];
    description = json['description'];
    picture = json['picture'];
    notifyFor = json['notifyFor'];
    helperId = json['helperId'];
    type = json['type'];
    date = json['date'];
    userId = json['userId'];
    isRead = json['isRead'];
    createdAt = json['createdAt'];
    deleted = json['deleted'];
    id = json['id'];
    creationDate = json['creationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notifyId'] = this.notifyId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['picture'] = this.picture;
    data['notifyFor'] = this.notifyFor;
    data['helperId'] = this.helperId;
    data['type'] = this.type;
    data['date'] = this.date;
    data['userId'] = this.userId;
    data['isRead'] = this.isRead;
    data['createdAt'] = this.createdAt;
    data['deleted'] = this.deleted;
    data['id'] = this.id;
    data['creationDate'] = this.creationDate;
    return data;
  }
}

void notificationNavigator(
    {required BuildContext context, required Notifications notification}) {
  var type = notification.type;
  switch (type) {
    case 0:
      // context.push(AppRoutes.s, extra: notification.helperId);
      break;
    case 1:
      // context.push(AppRoutes.orderDetails,
      //     extra: OrderDetailsArgs(
      //       id: notification.helperId!,
      //     ));
      break;
    case 2:
      // Navigator.pushNamed(context, '/home');
      break;
    case 3:
      // Navigator.pushNamed(context, '/home');
      break;
  }
}
