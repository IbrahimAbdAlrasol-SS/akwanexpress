import 'dart:math';

import 'package:Tosell/Features/changeState/screens/scanner_screen.dart';
import 'package:Tosell/Features/home/screens/vip/vip_order_screen.dart';
import 'package:Tosell/Features/order/screens/order_details_screen.dart';
import 'package:Tosell/Features/order/screens/verification_dialog.dart';
import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:Tosell/Features/shipments/providers/orders_provider.dart';
import 'package:Tosell/Features/shipments/providers/shipments_provider.dart';
import 'package:Tosell/Features/shipments/widgets/formatArabicDate.dart';
import 'package:Tosell/Features/shipments/widgets/order_card_item.dart';
import 'package:Tosell/Features/shipments/widgets/shipment_cart_item.dart';
import 'package:Tosell/Features/support/providers/ticket_provider.dart';
import 'package:Tosell/Features/support/screens/add_ticket_dailog.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/OutlineButton.dart';
import 'package:Tosell/core/widgets/custom_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PickupShipmentDetailsScreen extends ConsumerStatefulWidget {
  final String shipmentId;
  const PickupShipmentDetailsScreen({super.key, required this.shipmentId});

  @override
  ConsumerState<PickupShipmentDetailsScreen> createState() =>
      _PickupShipmentDetailsScreenState();
}

class _PickupShipmentDetailsScreenState
    extends ConsumerState<PickupShipmentDetailsScreen> {
  bool isLoading = false;
  bool confirmLoading = false;
  late bool justAssigned;

  late bool picked;
  @override
  Widget build(BuildContext context) {
    final shipmentState = ref.watch(getShipmentByIdProvider(widget.shipmentId));

    return shipmentState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Center(child: Text(err.toString())),
      data: (shipment) {
        justAssigned = shipment?.status == 1;

        picked = (shipment?.orderStatus == 4);
        return _buildUi(context, shipment);
      },
    );
  }

  Widget _buildUi(BuildContext context, Shipment? shipment) {
    return Scaffold(
      key: Key(shipment.hashCode.toString()),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(shipmentsNotifierProvider.notifier)
              .getById(shipmentId: widget.shipmentId);
          ref.invalidate(getShipmentByIdProvider(widget.shipmentId));
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomAppBar(
                        // padding: EdgeInsets.all(0),
                        title: 'تفاصيل الطلب',
                        showBackButton: true,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var description = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 24),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: double.infinity,
                                  ),
                                  child: const SingleChildScrollView(
                                    padding: EdgeInsets.zero,
                                    child: AddTicketDialog(),
                                  ),
                                ),
                              );
                            },
                          );
                          var result = await ref
                              .read(ticketNotifierProvider.notifier)
                              .createShipmentTicket(
                                  shipmentId: shipment!.id!,
                                  description: description);

                          if (result?.singleData == null) {
                            GlobalToast.show(
                              context: context,
                              message: result?.message ?? 'server problem',
                            );
                          } else {
                            context.push(
                              AppRoutes.chat,
                              extra: result?.singleData?.id,
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                context.colorScheme.primary.withOpacity(0.15),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            border: Border.all(
                              color: context.colorScheme.primary,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              "assets/svg/support.svg",
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomSection(
                title: "الطلبات المستلمة من التاجر",
                icon: SvgPicture.asset(
                  "assets/svg/User.svg",
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                childrenRadius: const BorderRadius.all(Radius.circular(16)),
                children: [
                  buildOrderSection(
                    Theme.of(context),
                    padding: const EdgeInsets.only(bottom: 3, top: 3),
                    subWidget: Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 28.0,
                          lineWidth: 6.0,
                          percent: (shipment!.receivedOrders!) /
                              (shipment.ordersCount!),
                          center: Text(
                              "${shipment.receivedOrders!} / ${shipment.ordersCount!}"),
                          progressColor: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const Gap(AppSpaces.small),
                        Text(
                            "تم إستلام ${shipment.receivedOrders!} طلب من أصل ${shipment.ordersCount!}"),
                      ],
                    ),
                  ),
                ],
              ),
              buildUserInfo(
                context,
                shipment.orders!.first,
              ),
              CustomSection(
                title: "معلومات القائمة ",
                icon: SvgPicture.asset(
                  "assets/svg/User.svg",
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                childrenRadius: const BorderRadius.all(Radius.circular(16)),
                children: [
                  buildOrderSection(
                    title: "رقم القائمة",
                    Theme.of(context),
                    padding: const EdgeInsets.only(bottom: 3, top: 3),
                    subWidget: Text(shipment.code ?? "لايوجد"),
                  ),
                  buildOrderSection(
                    title: "تاريخ الإنشاء",
                    Theme.of(context),
                    padding: const EdgeInsets.only(bottom: 3, top: 3),
                    subWidget: Text(
                      shipment.creationDate != null
                          ? formatArabicDate(
                              DateTime.parse(shipment.creationDate!))
                          : "لايوجد",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  buildOrderSection(
                    title: "حالة القائمة",
                    Theme.of(context),
                    padding: const EdgeInsets.only(bottom: 3, top: 3),
                    subWidget: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Row(
                        children: [
                          buildShipmentStatus(shipment.status!, shipment.type!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              CustomSection(
                title: "معلومات الطلبات",
                hasDivider: false,
                icon: SvgPicture.asset(
                  "assets/svg/User.svg",
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                childrenRadius: const BorderRadius.all(Radius.circular(16)),
                children: shipment.orders
                        ?.map(
                          (order) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: GestureDetector(
                              onTap: () {},
                              child: OrderCardItem(
                                order: order,
                                isPickup: true,
                              ),
                            ),
                          ),
                        )
                        .toList() ??
                    [],
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: picked
          ? null
          : Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: FillButton(
                            isLoading: isLoading,
                            label: (justAssigned)
                                ? 'في الطريق الى التاجر'
                                : 'مسح الرمز',
                            onPressed: (justAssigned)
                                ? () async {
                                    // todo : addd forom wear house logic
                                    _setLoadingState(true);

                                    var result = await ref
                                        .read(
                                            shipmentsNotifierProvider.notifier)
                                        .inPickupProgress(
                                          shipmentId: widget.shipmentId,
                                        );
                                    _setLoadingState(false);
                                    if (result.$1 != null) {
                                      GlobalToast.show(
                                        context: context,
                                        backgroundColor: Colors.green,
                                        message: 'تم تغيير الحالة',
                                      );
                                    } else {
                                      GlobalToast.show(
                                        context: context,
                                        backgroundColor:
                                            context.colorScheme.error,
                                        message: result.$2 ?? "unknown error",
                                      );
                                    }
                                    ref.invalidate(
                                        getShipmentByIdProvider(shipment.id!));
                                  }
                                : () async {
                                    await context.push(
                                      AppRoutes.scannerScreen,
                                      extra: ScannerArgs(
                                        getValue: false,
                                        scannedCodes: shipment.orders
                                            ?.where(
                                                (order) => order.status == 4)
                                            .map((order) => order.code!)
                                            .toList(),
                                        shipmentId: shipment.id!,
                                        totalCount:
                                            shipment.orders?.length ?? 0,
                                        scanOrders: (code, shipmentId) async {
                                          return await ref
                                              .read(ordersNotifierProvider
                                                  .notifier)
                                              .getOrderByCode(
                                                  code: code,
                                                  shipmentId: shipmentId);
                                        },
                                        receiveOrder:
                                            (code, shipmentId, isVip) async {
                                          return await ref
                                              .read(ordersNotifierProvider
                                                  .notifier)
                                              .receivedOrder(
                                                code: code,
                                                shipmentId: shipmentId,
                                                isVip: isVip,
                                              );
                                        },
                                      ),
                                    );

                                    ref.invalidate(
                                        getShipmentByIdProvider(shipment.id!));
                                  }),
                      ),
                      if (!(justAssigned) && !picked)
                        const Gap(AppSpaces.small),
                      // if (false) const Gap(AppSpaces.small),
                      if (!(justAssigned) && !picked)
                        // if (false)
                        Expanded(
                          child: OutlinedCustomButton(
                            isLoading: isLoading,
                            label: 'تأكيد الإستلام',
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: VerificationDialog(
                                        order: shipment.orders!.first,
                                        shipment: shipment,
                                        notReceivedOrders: [
                                          ...shipment.orders!
                                              .where((e) => e.status! < 4)
                                        ],
                                        fromWarehouse: false,
                                      ),
                                    ),
                                  );
                                },
                              );

                              if (picked) {
                                setState(() {
                                  picked = true;
                                });
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _setLoadingState(bool state) {
    return setState(() {
      isLoading = state;
    });
  }
}
