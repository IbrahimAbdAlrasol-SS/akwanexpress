import 'dart:async';
import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Tosell/Features/shipments/services/orders_service.dart';

part 'orders_provider.g.dart';

@riverpod
class OrdersNotifier extends _$OrdersNotifier {
  final OrdersService _service = OrdersService();

  Future<ApiResponse<Order>> getAll(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    return (await _service.getOrders(queryParams: queryParams, page: page));
  }

  Future<(Order?, String?)> getOrderByCode(
      {required String shipmentId, required String code}) async {
    var result =
        await _service.getOrderByCode(shipmentId: shipmentId, code: code);

    return (result?.singleData, result?.message);
  }

  Future<Order?>? getOrderByIdAndShipmentId(
      {required String orderId, required String shipmentId}) async {
    return (await _service.getOrderByIdAndShipmentId(
        orderId: orderId, shipmentId: shipmentId));
  }

  Future<(Order?, String?)>? changeOrderSendingState(
      {required String orderId,
      required String shipmentId,
      required int status}) async {
    return (await _service.changeOrderSendingState(
        orderId: orderId, shipmentId: shipmentId, status: status));
  }

  Future<(Order?, String?)> atDeliveryPoint({required String orderId}) async {
    var result = await _service.atDeliveryPoint(orderId: orderId);
    invokeNearbyShipment();
    return result;
  }

  Future<(Order?, String?)> atPickupPoint({required String orderId}) async {
    var result = await _service.atPickupPoint(orderId: orderId);
    invokeNearbyShipment();
    return result;
  }

  Future<(Order?, String?)> delivered(
      {required String orderId, required String shipmentId}) async {
    var result =
        await _service.delivered(orderId: orderId, shipmentId: shipmentId);
    invokeNearbyShipment();

    return result;
  }

  Future<(Order?, String?)> verifyOtp(
      {required String orderId,
      bool isVip = true,
      String? note,
      required String shipmentId,
      required String otp}) async {
    var result = await _service.verifyOtp(
        otp: otp, orderId: orderId, shipmentId: shipmentId, note: note);
    if (result.$1 != null && isVip) {
      var changedOrder = assignedShipmentsNotifier.value
          .firstWhere((e) => e.order?.id == orderId);

      assignedShipmentsNotifier.value.remove(changedOrder);
    }
    invokeNearbyShipment();

    return result;
  }

  Future<(Order?, String?)> receivedOrder({
    bool isVip = true,
    required String code,
    required String shipmentId,
  }) async {
    var result =
        await _service.receivedOrder(code: code, shipmentId: shipmentId);
    if (result.$1 != null && isVip) {
      var changedOrder = assignedShipmentsNotifier.value
          .firstWhere((e) => e.order?.code == code);

      assignedShipmentsNotifier.value.remove(changedOrder);
    }
    return result;
  }

  // Future<(Order?, String?)> receivedFromWarHouse({
  //   required String code,
  //   required String shipmentId,
  // }) async {
  //   var result =
  //       await _service.receivedOrder(code: code, shipmentId: shipmentId);

  //   return result;
  // }

  Future<(Order?, String?)> deliveredOrder(
      {bool isVip = true,
      required String orderId,
      required String shipmentId,
      required List<String> attachments}) async {
    var result = await _service.deliveredOrder(
        attachments: attachments, orderId: orderId, shipmentId: shipmentId);
    if (result.$1 != null && isVip) {
      var changedOrder = assignedShipmentsNotifier.value
          .firstWhere((e) => e.order?.id == orderId);

      assignedShipmentsNotifier.value.remove(changedOrder);
    }
    return result;
  }

  Future<(Order?, String?)> delayOrReturnOrder({
    required String shipmentId,
    required String orderId,
    String? note,
    required int status,
    String? recycledTo,
    String? rejectReasonId,
  }) async {
    var result = await _service.delayOrReturnOrder(
      orderId: orderId,
      shipmentId: shipmentId,
      note: note,
      status: status,
      rejectReasonId: rejectReasonId,
    );

    return result;
  }

  Future<(Order?, String?)> reSendOtp({
    required String orderId,
  }) async {
    var result = await _service.reSendOtp(
      orderId: orderId,
    );

    return result;
  }

  Future<(Order?, String?)> setShipmentReceived({
    required String orderId,
  }) async {
    var result = await _service.reSendOtp(
      orderId: orderId,
    );

    return result;
  }

  @override
  FutureOr<List<Order>> build() async {
    var result = await getAll();
    return result.data ?? [];
  }
}
