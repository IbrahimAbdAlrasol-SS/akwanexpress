import 'dart:async';
import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/helpers/sharedPreferencesHelper.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_core/signalr_core.dart';

late HubConnection hubConnection;

/// Initializes the SignalR connection and sets up the shipment listener
Future<void> initSignalRConnection(ProviderContainer container) async {
  final user = await SharedPreferencesHelper.getUser();

  hubConnection = HubConnectionBuilder()
      .withUrl(
        imageUrl + 'hubs/location',
        HttpConnectionOptions(
          transport: HttpTransportType.webSockets,
          logging: (level, message) => print(message),
          accessTokenFactory: () async => user?.token,
        ),
      )
      .withAutomaticReconnect()
      .build();

  Future<void> receiveNearbyShipment() async {
    final userId = user?.id;

    if (hubConnection.state == HubConnectionState.connected && userId != null) {
      hubConnection.off(userId); // Avoid duplicate listeners
// NewShipment
      hubConnection.on(userId, (arguments) {
        try {
          if (arguments == null) {
            return;
          }

          final List<dynamic> assignedShipments =
              arguments.first as List<dynamic>;

          final List<dynamic> unAssignedShipments =
              arguments[1] as List<dynamic>;

          final List<ShipmentInMap> assignedShipmentsResult = assignedShipments
              .map((e) => ShipmentInMap.fromJson(e as Map<String, dynamic>))
              // .where((a) => a.orderStatus != 10)
              .toList();

          final List<ShipmentInMap> unAssignedShipmentsResult =
              unAssignedShipments
                  .map((e) => ShipmentInMap.fromJson(e as Map<String, dynamic>))
                  // .where((a) => a.orderStatus != 10)
                  .toList();

          assignedShipmentsNotifier.value = assignedShipmentsResult;
          unAssignedShipmentsNotifier.value = unAssignedShipmentsResult;

          // إجبار إشعار المستمعين
          assignedShipmentsNotifier.notifyListeners();
          unAssignedShipmentsNotifier.notifyListeners();

          print('📦 تم استلام بيانات جديدة من SignalR:');
          print('   - الطلبات المقبولة: ${assignedShipmentsResult.length}');
          print(
              '   - الطلبات غير المقبولة: ${unAssignedShipmentsResult.length}');

          // طباعة تفاصيل الطلبات المقبولة
          for (var shipment in assignedShipmentsResult) {
            print(
                '   📋 طلب مقبول: ${shipment.code} - الحالة: ${shipment.status}');
          }

          // طباعة تفاصيل الطلبات غير المقبولة
          for (var shipment in unAssignedShipmentsResult) {
            print(
                '   📋 طلب غير مقبول: ${shipment.code} - الحالة: ${shipment.status}');
          }

          // إجبار تحديث الشاشات باستخدام عدة طرق
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('🔄 إجبار تحديث الشاشات...');
            // إجبار إشعار المستمعين مرة أخرى بعد إطار واحد
            assignedShipmentsNotifier.notifyListeners();
            unAssignedShipmentsNotifier.notifyListeners();

            // استخدام ShipmentDataManager للتحديث الفوري
            ShipmentDataManager.immediateRefreshShipments();
          });
        } catch (e, _) {
          print('❌ Error parsing shipment list: $e');
        }
      });
    } else {
      print('🚫 SignalR not connected or user ID is null');
    }
  }

  try {
    await hubConnection.start();
    print('✅ SignalR connected');
    await receiveNearbyShipment();
  } catch (e, stack) {
    print('❌ SignalR error: $e');
    print(stack);
  }

  hubConnection.on('VipShipmentsCount', (arguments) {
    //! Ignored intentionally
  });
}
