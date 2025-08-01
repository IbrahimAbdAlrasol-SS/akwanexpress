import 'package:flutter/material.dart';

class ShipmentEnum {
  String? name;
  Color? textColor;
  String? icon;
  Color? iconColor;
  Color? color;
  String? description;
  int? value;

  ShipmentEnum({
    this.name,
    this.icon,
    this.color,
    this.value,
    this.description,
    this.iconColor,
    this.textColor,
  });
}

var shipmentStatus = [
  //? index = 0
  ShipmentEnum(
      name: 'في الانتطار',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      icon: 'assets/svg/box.svg',
      // description: 'الشحنة قيد انتظار الموافقة',
      value: 0),

  //? index = 1
  ShipmentEnum(
      name: 'تم تعيينك',
      color: const Color(0xFFE5F6FF),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      // description: 'في قائمة الاستحصال',
      value: 1),

  //? index = 2
  ShipmentEnum(
      name: 'في الطريق',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      // description: 'المندوب عند التاجر',
      value: 4),

  //? index = 3
  ShipmentEnum(
      name: 'في الطريق',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      // description: 'المندوب عند التاجر',
      value: 5),

  //? index = 4
  ShipmentEnum(
      name: 'ملغبة',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      // description: ' طلبك قيد الاستحصال من قبل المندوب',
      value: 2),
  //? index = 5
  ShipmentEnum(
      name: 'مكتملة',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      // description: 'المندوب عند التاجر',
      value: 3),

  //? index =6
  ShipmentEnum(
      name: 'مدفوع جزئي',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'تم استحصال الطلب من قبل المندوب',
      value: 6),

  //? index = 7
  ShipmentEnum(
      name: 'مدفوع',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      description: 'لم يتم استحصال الطلب من قبل المندوب',
      value: 7),

  //? index = 8
  ShipmentEnum(
      name: 'مكتمل غير مجمع',
      color: const Color(0xFFE8FCF5),
      iconColor: Colors.black,
      textColor: Colors.black,
      icon: 'assets/svg/box.svg',
      // description: 'تم وصول الطلب الى المخزن',
      value: 8),
];
