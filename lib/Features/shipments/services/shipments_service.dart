import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';

class ShipmentsService {
  final BaseClient<Shipment> baseClient;

  ShipmentsService()
      : baseClient =
            BaseClient<Shipment>(fromJson: (json) => Shipment.fromJson(json));

  Future<ApiResponse<Shipment>> getAll(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/shipment/my-shipments',
          page: page,
          queryParams: queryParams);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Shipment>> getById({required String id}) async {
    try {
      var result =
          await baseClient.getById(endpoint: '/shipment', id: id + '/delegate');
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Shipment>> allOrderReceived(
      {required String shipmentId, required List<String> attachments}) async {
    try {
      List<String> newAttachments = [];
      for (var attachment in attachments) {
        var path = (await baseClient.uploadFile(attachment)).data![0];
        newAttachments.add(path);
      }
      var result = await baseClient
          .update(endpoint: '/shipment/$shipmentId/attachment', data: {
        'attachments': newAttachments,
      });
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Future<ApiResponse<Shipment>> receivedShipment(
  //     {required String shipmentId, required List<String> attachments}) async {
  //   try {
  //     List<String> newAttachments = [];
  //     for (var attachment in attachments) {
  //       var result = await baseClient.uploadFile(attachment);
  //       newAttachments.add(result.data![0]);
  //     }
  //     var result = await baseClient.update(
  //         endpoint: '/shipment/$shipmentId/status/received',
  //         data: {'attachments': newAttachments});
  //     return result;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<ApiResponse<Shipment>> inPickupProgress(
      {required String shipmentId}) async {
    try {
      var result =
          await baseClient.update(endpoint: '/shipment/$shipmentId/hand-over');

      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Shipment>> setShipmentReceived({
    required String shipmentId,
  }) async {
    try {
      var result = await baseClient.update(
        endpoint: '/shipment/$shipmentId/status/received',
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<(Shipment?, String?)> receivedOrderFromWareHouse(
      {required String code, required String shipmentId}) async {
    try {
      var result = await baseClient.update(
          endpoint: '/shipment/$shipmentId/order/in-progress',
          data: {'code': code});
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Shipment?, String?)> allDelivered(
      {required String shipmentId}) async {
    try {
      var result = await baseClient.update(
          endpoint: '/shipment/$shipmentId/status/Delivered');
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Shipment?, String?)> vipReceived(
      {required String shipmentId, required List<String> attachments}) async {
    List<String> newAttachments = [];
    try {
      for (var attachment in attachments) {
        var path = (await baseClient.uploadFile(attachment)).data![0];
        newAttachments.add(path);
      }
      var result = await baseClient.update(
          endpoint: '/shipment/$shipmentId/status/vip-received',
          data: {'attachments': newAttachments});
      invokeNearbyShipment();
      return (result.singleData, result.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Shipment>> assign({required String shipmentId}) async {
    try {
      var result = await baseClient.update(
          endpoint: '/shipment/$shipmentId/delegate/accept');

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
