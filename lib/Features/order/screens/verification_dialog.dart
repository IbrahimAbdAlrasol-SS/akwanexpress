import 'package:Tosell/Features/changeState/screens/otp_dialog.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';
import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:Tosell/Features/shipments/providers/orders_provider.dart';
import 'package:Tosell/Features/shipments/providers/shipments_provider.dart';
import 'package:Tosell/Features/shipments/widgets/order_card_item.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/OutlineButton.dart';
import 'package:Tosell/core/widgets/custom_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class VerificationDialog extends ConsumerStatefulWidget {
  final Order order;
  final Shipment shipment;
  final bool fromWarehouse;
  final List<Order> notReceivedOrders;
  const VerificationDialog({
    super.key,
    required this.order,
    required this.shipment,
    this.notReceivedOrders = const [],
    required this.fromWarehouse,
  });

  @override
  ConsumerState<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends ConsumerState<VerificationDialog> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var order = widget.order;
    var fromWarehouse = widget.fromWarehouse;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        minWidth: double.infinity,
      ),
      child: SingleChildScrollView(
        child: CustomSection(
          title: fromWarehouse
              ? 'تأكيد الاستلام من المخزن'
              : 'تأكيد الاستلام من التاجر',
          icon: SvgPicture.asset(
            "assets/svg/box.svg",
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: context.colorScheme.outline),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircularPercentIndicator(
                                  radius: 28.0,
                                  lineWidth: 6.0,
                                  percent:
                                      (widget.shipment.receivedOrders ?? 0) /
                                          (widget.shipment.ordersCount ??
                                              1), // prevent div by zero
                                  center: Text(
                                      "${widget.shipment.receivedOrders} / ${widget.shipment.ordersCount}"),
                                  progressColor: Colors.green,
                                  backgroundColor: Colors.grey.shade300,
                                  circularStrokeCap: CircularStrokeCap.round,
                                ),
                                const Gap(AppSpaces.small),
                                Expanded(
                                  child: Text(
                                    'تم استلام ${widget.shipment.receivedOrders} طلب من اصل ${widget.shipment.ordersCount}',
                                    style: context.textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            )),
                        const Gap(AppSpaces.medium),
                        fromWarehouse
                            ? Text(
                                'هل انت متأكد من إستلامك جميع الطلبات؟',
                                style: context.textTheme.bodyMedium!.copyWith(
                                  color: context.colorScheme.onSurface,
                                ),
                              )
                            : Text(
                                widget.notReceivedOrders.isNotEmpty
                                    ? 'هل تؤكد من إستلامك هذه الطلبات التي لم تقم بمسح رمزها؟'
                                    : 'هل انت متأكد من إستلامك جميع الطلبات؟',
                                style: context.textTheme.bodyMedium!.copyWith(
                                  color: widget.notReceivedOrders.isNotEmpty
                                      ? context.colorScheme.error
                                      : context.colorScheme.onSurface,
                                ),
                              ),
                        (widget.notReceivedOrders.isNotEmpty && !fromWarehouse)
                            ? Column(
                                children: widget.notReceivedOrders
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: OrderCardItem(
                                            order: e,
                                            isPickup: true,
                                            onTap: () {},
                                          ),
                                        ))
                                    .toList(),
                              )
                            : const SizedBox.shrink(),
                      ],
                    )),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: FillButton(
                          isLoading: isLoading,
                          borderRadius: 8,
                          label: 'تأكيد',
                          color: Colors.green,
                          onPressed: fromWarehouse
                              ? () async {
                                  _setLoadingState(true);
                                  var result = await ref
                                      .read(ordersNotifierProvider.notifier)
                                      .receivedOrder(
                                        isVip: false,
                                        code: order.code!,
                                        shipmentId: widget.shipment.id ?? '',
                                      );
                                  _setLoadingState(false);

                                  if (result.$1 != null) {
                                    GlobalToast.show(
                                      context: context,
                                      message: 'تم تاكيد استلامك للطلب',
                                      backgroundColor: Colors.green,
                                    );

                                    var isVip = widget.shipment.type == 2;
                                    if (context.mounted) {
                                      isVip
                                          ? context.go(AppRoutes.vipHome)
                                          : context.go(AppRoutes.shipments);
                                    }
                                    ref.invalidate(getShipmentByIdProvider(
                                        widget.shipment.id!));
                                  } else {
                                    GlobalToast.show(
                                      context: context,
                                      message: result.$2 ?? 'حدث خطأ ما',
                                      backgroundColor:
                                          context.colorScheme.error,
                                    );
                                  }
                                }
                              : () async {
                                  _setLoadingState(true);
                                  //TODO : add received from warehouse logic
                                  var result = await ref
                                      .read(shipmentsNotifierProvider.notifier)
                                      .setShipmentReceived(
                                        shipmentId: widget.shipment.id!,
                                      );
                                  _setLoadingState(false);

                                  if (result.$1 != null) {
                                    GlobalToast.show(
                                      context: context,
                                      message: 'تم تاكيد استلامك للطلبات',
                                      backgroundColor: Colors.green,
                                    );
                                    ref.invalidate(getShipmentByIdProvider(
                                        widget.shipment.id!));
                                    context.pop();
                                  } else {
                                    GlobalToast.show(
                                      context: context,
                                      message: result.$2 ?? 'حدث خطأ ما',
                                      backgroundColor:
                                          context.colorScheme.error,
                                    );
                                  }
                                },
                        ),
                      ),
                      const Gap(AppSpaces.exSmall),
                      Expanded(
                        child: OutlinedCustomButton(
                          borderRadius: 8,
                          borderColor: context.colorScheme.outline,
                          textColor: context.colorScheme.error,
                          label: 'الرجوع',
                          // colxor: context.colorScheme.error,
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setLoadingState(bool state) {
    return setState(() {
      isLoading = state;
    });
  }

//   Widget _buildUserInfo(bool isPickup, Order order, BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: context.colorScheme.outline),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: CustomAppBar(
//           padding: const EdgeInsets.only(),
//           title: isPickup
//               ? '${order.pickupZone?.name} , ${order.pickupZone?.governorate?.name}'
//               : '${order.deliveryZone?.name} , ${order.deliveryZone?.governorate?.name}',
//           titleStyle: context.textTheme.bodyMedium!.copyWith(
//             fontWeight: FontWeight.w500,
//           ),
//           showBackButton: false,
//           subtitle: isPickup
//               ? order.customerName
//               : order.merchant?.brandName ?? 'لايوجد',
//           secondSubtitle: order.customerPhoneNumber,
//           subTitleStyle: context.textTheme.titleSmall!.copyWith(
//             fontSize: 14,
//             color: context.colorScheme.secondary,
//           ),
//           buttonWidget: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               color: const Color(0xff698596),
//             ),
//             width: 40,
//             height: 40,
//           ),
//         ),
//       ),
//     );
//   }

//   Container _buildInvoice(BuildContext context, Order order) {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: context.colorScheme.outline,
//           )),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             buildPriceRow(
//               label: 'سعر الطلب',
//               amount: '${formatPrice(order.amount)} د.ع',
//               labelStyle: const TextStyle(color: Colors.grey),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: Divider(
//                   color: context.colorScheme.secondary.withOpacity(0.5)),
//             ),
//             buildPriceRow(
//               label: 'المجموع الكلي',
//               amount: '${formatPrice(order.amount)} د.ع',
//               labelStyle: context.textTheme.bodyMedium!.copyWith(
//                 color: context.colorScheme.primary,
//                 fontWeight: FontWeight.bold,
//               ),
//               amountStyle: const TextStyle(
//                 color: Colors.blue,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
}
