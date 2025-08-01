import 'package:flutter/material.dart';

class TicketEnum {
  String? name;
  Color? textColor;
  String? icon;
  Color? iconColor;

  Color? color;
  String? description;
  int? value;

  TicketEnum({
    this.name,
    this.icon,
    this.color,
    this.value,
    this.description,
    this.iconColor,
    this.textColor,
  });
}

var orderStatus = [
  //? index = 0
  TicketEnum(
      name: 'في الانتطار',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'طلبك قيد انتظار الموافقة',
      value: 0),
  //? index = 1
  TicketEnum(
      name: 'قائمة استحصال',
      color: const Color(0xFFE5F6FF),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'في قائمة الاستحصال',
      value: 1),
  //? index = 2
  TicketEnum(
      name: 'قيد الاستحصال',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: ' طلبك قيد الاستحصال من قبل المندوب',
      value: 2),
  //? index = 3
  TicketEnum(
      name: 'عند التاجر',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'المندوب عند التاجر',
      value: 3),

  //? index =4
  TicketEnum(
      name: 'تم الاستحصال',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم استحصال الطلب من قبل المندوب',
      value: 4),
  //? index = 5
  TicketEnum(
      name: 'غير مستحصل',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'لم يتم استحصال الطلب من قبل المندوب',
      value: 5),
  //? index = 6
  TicketEnum(
      name: 'في المخزن',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم وصول الطلب الى المخزن',
      value: 6),
  //? index = 7
  TicketEnum(
      name: 'قائمة التوصيل',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'طلبك في قائمة التوصيل للزبون',
      value: 7),
  //? index = 8
  TicketEnum(
      name: 'قيد التوصيل',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'طلبك قيد التوصيل للزبون',
      value: 8),

  // ? index = 9
  TicketEnum(
      name: 'عند الزبون',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'المندوب عند الزبون',
      value: 9),
  // ? index = 10
  TicketEnum(
      name: 'تم التوصيل',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم ايصال الطلب للزبون',
      value: 10),
  //? index = 11
  TicketEnum(
      name: 'توصيل جزئي',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم الايصال الجزئي للزبون',
      value: 11),
  //? index = 12
  TicketEnum(
      name: 'ملغية',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم اعادة جدولة موعد الطلب',
      value: 12),
  //? index = 13
  TicketEnum(
      name: 'منتهي',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم الغاء الطلب',
      value: 13),
  //? index = 14
  TicketEnum(
      name: 'مؤجل في المخزن',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم ارجاع الطلب للمندوب',
      value: 14),
  //? index = 15
  TicketEnum(
      name: 'مؤجل عند المندوب',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم تصفية الحساب',
      value: 15),

  //? index = 16
  TicketEnum(
      name: 'مرجع في المخزن',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم تصفية الحساب',
      value: 15),

  //? index = 17
  TicketEnum(
      name: 'مرحع عند السائق',
      color: Colors.red.withOpacity(0.5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم تصفية الحساب',
      value: 15),

//? 0-        Pending,  - في الانتظار
//? 1-        InPickUpShipment, - استحصال قائمة
//? 2-        InPickUpProgress, - قيد الاستحصال
//? 3-        AtPickUpPoint, - عند التاجر
//? 4-        Received, - تم الاستحصال
//? 5-        NotReceived, - لم يتم الاستحصال
//? 6-        InWarehouse, - في المخزن
//? 7-        InDeliveryShipment, - قائمة التوصيل
//? 8-        InDeliveryProgress, - قيد التوصيل
//? 9-        AtDeliveryPoint, - عند الزبون
//? 10-        Delivered, - تم التوصيل
//? 11-       PartiallyDelivered, - توصيل جزئي
//? 12-       Rescheduled, - اعادة جدولة
//? 13-       Cancelled, - ملغي
//? 14-       Refunded, - مرتجع
//? 15-       Completed, - منتهي
];

// ignore: unused_element

class OrderSizeEnum {
  String? name;

  int? value;

  OrderSizeEnum({
    this.name,
    this.value,
  });
}

var orderSizes = [
  OrderSizeEnum(name: 'صغير', value: 0),
  OrderSizeEnum(name: 'متوسط', value: 1),
  OrderSizeEnum(name: 'كبير', value: 2),
];
