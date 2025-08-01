import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:Tosell/Features/shipments/models/shipment_enum.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ShipmentCartItem extends ConsumerStatefulWidget {
  final Shipment shipment;
  final bool showState;
  final Function? onTap;

  const ShipmentCartItem({
    required this.shipment,
    this.onTap,
    this.showState = false,
    super.key,
  });

  @override
  ConsumerState<ShipmentCartItem> createState() => _ShipmentCartItemState();
}

class _ShipmentCartItemState extends ConsumerState<ShipmentCartItem> {
  @override
  Widget build(BuildContext context) {
    var shipment = widget.shipment;
    var isPickup = shipment.type == 0;
    var title = '';
    switch (shipment.type) {
      case 0: //? pickup
        title =
            '${shipment.orders?.firstOrNull?.pickupZone?.name} , ${shipment.orders?.firstOrNull?.pickupZone?.governorate?.name}';
        break;
      case 1: //? delivery
        title = 'قائمة - ${widget.shipment.code}';
        break;
      case 2: //? refound
        title =
            '${shipment.orders?.firstOrNull?.pickupZone?.name} , ${shipment.orders?.firstOrNull?.pickupZone?.governorate?.name}';
        break;
      default:
        title = '"قائمة - ${widget.shipment.code}"';
    }
    return GestureDetector(
      onTap: () {
        switch (shipment.type) {
          case 0:
            context.push(AppRoutes.pickupShipmentDetails,
                extra: widget.shipment.id);
            break;
          case 1:
            context.push(AppRoutes.deliveryShipmentDetails,
                extra: widget.shipment.id);
            break;
          case 2:
            context.push(AppRoutes.refoundShipmentDetails,
                extra: widget.shipment.id);
            break;
          default:
            () {};
        }
        // isPickup
        //   ? context.push(
        //       AppRoutes.pickupShipmentDetails,
        //       extra: widget.shipment.id,
        //     )
        //   : context.push(
        //       AppRoutes.deliveryShipmentDetails,
        //       extra: widget.shipment.id,
        //     );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            if (widget.showState)
              buildShipmentStatus(widget.shipment.status!, shipment.type!),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          '${widget.shipment.merchant?.brandName ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SvgPicture.asset(
                          'assets/svg/warehouse-stroke-rounded.svg',
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            //? Progress Circle
            CircularPercentIndicator(
              radius: 28.0,
              lineWidth: 6.0,
              percent: (isPickup
                      ? (shipment.receivedOrders!)
                      : (shipment.deliveredOrders!)) /
                  (shipment.ordersCount!),
              center: Text(
                  "${isPickup ? shipment.receivedOrders! : shipment.deliveredOrders!} / ${shipment.ordersCount!}"),
              progressColor: Colors.green,
              backgroundColor: Colors.grey.shade300,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildShipmentStatus(int index, int type) {
  var stateName = shipmentStatus[index].name!;
  return Container(
    height: 32,
    decoration: BoxDecoration(
      color: shipmentStatus[index].color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(index == 2
            ? type == 0
                ? stateName + ' الى التاجر'
                : stateName + ' الى المخزن'
            : index == 3
                ? type == 0
                    ? stateName + ' الى المخزن'
                    : type == 2
                        ? stateName + ' الى التاجر'
                        : stateName + ' الى الزبون'
                : stateName),
      ),
    ),
  );
}
