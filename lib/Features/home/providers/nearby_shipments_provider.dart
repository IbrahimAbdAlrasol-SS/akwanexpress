import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';
import 'package:flutter/material.dart';
import 'dart:async';

final assignedShipmentsNotifier = ValueNotifier<List<ShipmentInMap>>([]);

final unAssignedShipmentsNotifier = ValueNotifier<List<ShipmentInMap>>([]);

final currentLocationNotifier = ValueNotifier<LocationWithHeading?>(null);

// آلية لإجبار تحديث البيانات
class ShipmentDataManager {
  static Timer? _debounceTimer;

  // دالة لإجبار تحديث البيانات مع تأخير لتجنب الطلبات المتكررة
  static void forceRefreshShipments() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        print('🔄 إجبار تحديث البيانات...');
        await invokeNearbyShipment();

        // إجبار إشعار المستمعين
        assignedShipmentsNotifier.notifyListeners();
        unAssignedShipmentsNotifier.notifyListeners();
      } catch (e) {
        print('❌ خطأ في إجبار تحديث البيانات: $e');
      }
    });
  }

  // دالة لإجبار تحديث فوري بدون تأخير
  static void immediateRefreshShipments() {
    _debounceTimer?.cancel();
    Future.microtask(() async {
      try {
        print('⚡ تحديث فوري للبيانات...');
        await invokeNearbyShipment();

        // إجبار إشعار المستمعين
        assignedShipmentsNotifier.notifyListeners();
        unAssignedShipmentsNotifier.notifyListeners();
      } catch (e) {
        print('❌ خطأ في التحديث الفوري: $e');
      }
    });
  }
}
