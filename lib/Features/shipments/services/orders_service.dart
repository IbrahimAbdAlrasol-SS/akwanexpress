import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';

class OrdersService {
  final BaseClient<Order> baseClient;

  OrdersService()
      : baseClient =
            BaseClient<Order>(fromJson: (json) => Order.fromJson(json));

  Future<ApiResponse<Order>> getOrders(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/order/delegate', page: page, queryParams: queryParams);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order?, String?)> changeOrderState({String? id}) async {
    try {
      var result =
          await baseClient.update(endpoint: '/order/$id/status/received');
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order?, String?)> changeOrderSendingState(
      {required String orderId,
      required String shipmentId,
      int? status}) async {
    try {
      var result = await baseClient.update(
          endpoint: '/order/$orderId/status-by-delegate',
          data: {'status': status, 'shipmentId': shipmentId});
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<Order?>? getOrderById({required String id}) async {
    try {
      var result = await baseClient.getById(endpoint: '/order', id: id);
      return result.singleData;
    } catch (e) {
      rethrow;
    }
  }

  Future<Order?>? getOrderByIdAndShipmentId(
      {required String orderId, required String shipmentId}) async {
    try {
      var result = await baseClient.getById(
          endpoint: '/shipment/$shipmentId/order', id: orderId);
      return result.singleData;
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order?, String?)> atDeliveryPoint({required String orderId}) async {
    try {
      var result = await baseClient.update(
          endpoint: '/order/$orderId/status/at-delivery-point');

      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order?, String?)> atPickupPoint({required String orderId}) async {
    try {
      var result = await baseClient.update(
        endpoint: '/order/$orderId/status/at-pickup-point',
      );

      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order?, String?)> delivered(
      {required String orderId, required String shipmentId}) async {
    try {
      var result = await baseClient.update(
          endpoint: '/order/$orderId/status/delivered',
          data: {'shipmentId': shipmentId});
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order?, String?)> verifyOtp(
      {required String otp,
      required String orderId,
      String? note,
      required String shipmentId}) async {
    try {
      var result = await baseClient.update(
          endpoint: '/order/$orderId/status/delivered/verify',
          data: {'shipmentId': shipmentId, 'otp': otp, 'note': note});
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order?, String?)> receivedOrder(
      {required String code, required String shipmentId}) async {
    try {
      var result = await baseClient
          .update(endpoint: '/shipment/$shipmentId/order/received', data: {
        'code': code,
      });
      return (result.singleData, result.message);
    } catch (e) {
      return (null, e.toString());
    }
  }

  // Future<(Order?, String?)> receivedOrderFromWarHouse(
  //     {required String code, required String shipmentId}) async {
  //   try {
  //     var result = await baseClient.update(
  //         endpoint: '/shipment/$shipmentId/status/received-warehouse');
  //     return (result.singleData, result.message);
  //   } catch (e) {
  //     return (null, e.toString());
  //   }
  // }

  Future<(Order?, String?)> deliveredOrder(
      {required List<String> attachments,
      required String orderId,
      required String shipmentId}) async {
    List<String> newAttachments = [];
    try {
      for (var attachment in attachments) {
        var path = (await baseClient.uploadFile(attachment)).data![0];
        newAttachments.add(path);
      }
      var result = await baseClient.update(
          endpoint: '/order/$orderId/status/delivered',
          data: {'shipmentId': shipmentId, 'attachments': newAttachments});
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order?, String?)> reSendOtp({
    required String orderId,
  }) async {
    try {
      var result = await baseClient.update(
        endpoint: '/order/$orderId/resend-otp',
      );
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order?, String?)> delayOrReturnOrder({
    required String orderId,
    required String shipmentId,
    String? note,
    String? rejectReasonId,
    required int status,
  }) async {
    try {
      var result = await baseClient.update(
        endpoint: '/order/$orderId/status/other',
        data: {
          'shipmentId': shipmentId,
          'status': status,
          'note': note,
          // 'recycledTo': DateTime.now(),
          'rejectReasonId': rejectReasonId
        },
      );
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Order>>? getOrderByCode(
      {required String shipmentId, required String code}) async {
    try {
      var result = await baseClient.getById(
          endpoint: '/shipment/$shipmentId/order', id: code);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> validateCode({required String code}) async {
    try {
      var result =
          await BaseClient<bool>().get(endpoint: '/order$code/available');
      return result.singleData ?? false;
    } catch (e) {
      rethrow;
    }
  }
}
