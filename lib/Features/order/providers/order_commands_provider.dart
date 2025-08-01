import 'dart:async';
import 'package:Tosell/Features/home/screens/vip/vip_order_screen.dart';
import 'package:Tosell/Features/order/models/Location.dart';
import 'package:Tosell/Features/order/screens/order_details_screen.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Tosell/Features/shipments/services/orders_service.dart';

part 'order_commands_provider.g.dart';

@riverpod
class OrderCommandsNotifier extends _$OrderCommandsNotifier {
  final OrdersService _service = OrdersService();

  Future<(Order?, String?)> changeOrderState({required String id}) async {
    return (await _service.changeOrderState(id: id));
  }

  @override
  FutureOr<void> build() async {}
}

final getOrderByIdProvider =
    FutureProvider.family<Order?, String>((ref, id) async {
  final service = OrdersService(); // or inject via ref if needed
  return service.getOrderById(id: id);
});

final getOrderByIdAndShipmentIdProvider =
    FutureProvider.family<Order?, OrderDetailsArgs>((ref, args) async {
  final service = OrdersService(); // or inject via ref if needed
  return service.getOrderByIdAndShipmentId(
      orderId: args.id, shipmentId: args.shipment.id ?? '');
});

final getOrderByIdAndShipmentIdVipProvider =
    FutureProvider.family<Order?, VipOrderArgs>((ref, args) async {
  final service = OrdersService(); // or inject via ref if needed
  return service.getOrderByIdAndShipmentId(
      orderId: args.id, shipmentId: args.shipmentId);
});

final changeOrderStateProvider =
    FutureProvider.family<Order?, String>((ref, id) async {
  try {
    final service = OrdersService(); // or inject via ref if needed
    return service.getOrderById(id: id);
  } catch (e) {
    return (null);
  }
});
