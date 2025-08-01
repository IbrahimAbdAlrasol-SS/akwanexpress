import 'dart:async';
import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:Tosell/Features/shipments/services/shipments_service.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shipments_provider.g.dart';

@riverpod
class ShipmentsNotifier extends _$ShipmentsNotifier {
  final ShipmentsService _service = ShipmentsService();

  Future<ApiResponse<Shipment>> getAll(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    return (await _service.getAll(queryParams: queryParams, page: page));
  }

  Future<(Shipment?, String?)> setShipmentReceived(
      {required String shipmentId}) async {
    var result = (await _service.setShipmentReceived(shipmentId: shipmentId));

    return (result.singleData, result.message);
  }

  Future<(Shipment?, String?)> inPickupProgress(
      {required String shipmentId}) async {
    var result = await _service.inPickupProgress(
      shipmentId: shipmentId,
    );
    invokeNearbyShipment();
    return (result.singleData, result.message);
  }

  Future<(Shipment?, String?)> receivedOrderFromWareHouse({
    required String code,
    required String shipmentId,
  }) async {
    var result = await _service.receivedOrderFromWareHouse(
        code: code, shipmentId: shipmentId);

    return result;
  }

  Future<(Shipment?, String?)> allDelivered(
      {required String shipmentId}) async {
    var result = await _service.allDelivered(shipmentId: shipmentId);

    return result;
  }

  Future<(Shipment?, String?)> vipReceived(
      {required String shipmentId,
      required List<String> attachments,
      bool isVip = true}) async {
    var result = await _service.vipReceived(
        shipmentId: shipmentId, attachments: attachments);
    if (isVip) {
      invokeNearbyShipment();
    }
    return result;
  }

  Future<(Shipment?, String?)> getById({required String shipmentId}) async {
    var result = await _service.getById(
      id: shipmentId,
    );

    return (result.singleData, result.message);
  }

  Future<(Shipment?, String?)> allOrderReceived(
      {required String shipmentId, required List<String> attachments}) async {
    var result = await _service.allOrderReceived(
        shipmentId: shipmentId, attachments: attachments);

    return (result.singleData, result.message);
  }

  Future<(Shipment?, String?)> assign({required String shipmentId}) async {
    var result = await _service.assign(
      shipmentId: shipmentId,
    );
    invokeNearbyShipment();
    return (result.singleData, result.message);
  }

  @override
  FutureOr<List<Shipment>> build() async {
    var result = await getAll();
    return result.data ?? [];
  }
}

final getShipmentByIdProvider =
    FutureProvider.family<Shipment?, String>((ref, id) async {
  final service = ShipmentsService(); // or inject via ref if needed
  var result = await service.getById(id: id);
  return result.singleData;
});
