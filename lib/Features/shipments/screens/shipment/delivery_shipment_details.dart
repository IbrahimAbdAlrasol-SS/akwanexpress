import 'dart:math';

import 'package:Tosell/Features/changeState/screens/delivery_scanner_screen.dart';
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

class DeliveryShipmentDetails extends ConsumerStatefulWidget {
  final String shipmentId;
  const DeliveryShipmentDetails({super.key, required this.shipmentId});

  @override
  ConsumerState<DeliveryShipmentDetails> createState() =>
      _DeliveryShipmentDetailsState();
}

class _DeliveryShipmentDetailsState
    extends ConsumerState<DeliveryShipmentDetails> {
  bool isLoading = false;
  bool Loading2 = false;
  bool confirmLoading = false;
  late bool justAssigned;
  late bool fromWarehouse;

  @override
  Widget build(BuildContext context) {
    final shipmentState = ref.watch(getShipmentByIdProvider(widget.shipmentId));

    return shipmentState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Center(child: Text(err.toString())),
      data: (shipment) {
        justAssigned = shipment?.status == 1;
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
              const SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomAppBar(
                        // padding: EdgeInsets.all(0),
                        title: 'تفاصيل الطلب',
                        showBackButton: true,
                      ),
                    ],
                  ),
                ),
              ),
              CustomSection(
                title: "الطلبات الذي تم توصيله",
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
                          percent: ((shipment!.deliveredOrders!)) /
                              (shipment.ordersCount!),
                          center: Text(
                              "${shipment.deliveredOrders!} / ${shipment.ordersCount!}"),
                          progressColor: Colors.green,
                          backgroundColor: Colors.grey.shade300,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const Gap(AppSpaces.small),
                        Text(
                            'تم توصيل ${shipment.deliveredOrders!} طلب من أصل ${shipment.ordersCount!}'),
                      ],
                    ),
                  ),
                ],
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
                              onTap: () => context.push(
                                AppRoutes.orderDetails,
                                extra: OrderDetailsArgs(
                                  id: order.id!,
                                  shipment: shipment,
                                  isPickup: false,
                                ),
                              ),
                              child: OrderCardItem(
                                order: order,
                                isPickup: false,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: FillButton(
                    isLoading: isLoading,
                    label: justAssigned ? 'استلام - QR' : 'ابحث - QR',
                    onPressed: !(justAssigned)
                        ? () async {
                            await context.push(AppRoutes.deliveryScannerScreen,
                                extra: DeliveryScannerArgs(
                                  shipment: shipment,
                                ));
                          }
                        // ? () => scanAndNavigateToOrderDetails(
                        //       context: context,
                        //       ref: ref,
                        //       shipment: shipment,
                        //       setLoadingState: _setLoadingState,
                        // )
                        : () async {
                            //!  JustAssigned ==false  logic
                            await context.push(
                              AppRoutes.scannerScreen,
                              extra: ScannerArgs(
                                getValue: false,
                                scannedCodes: shipment.orders
                                    ?.where((order) => order.status == 4)
                                    .map((order) => order.code!)
                                    .toList(),
                                shipmentId: shipment.id!,
                                totalCount: shipment.orders?.length ?? 0,
                                scanOrders: (code, shipmentId) async {
                                  return await ref
                                      .read(ordersNotifierProvider.notifier)
                                      .getOrderByCode(
                                          code: code, shipmentId: shipmentId);
                                },
                                receiveOrder: (code, shipmentId, isVip) async {
                                  return await ref
                                      .read(shipmentsNotifierProvider.notifier)
                                      .receivedOrderFromWareHouse(
                                        code: code,
                                        shipmentId: shipmentId,
                                      );
                                },
                              ),
                            );
                            ref.invalidate(
                                getShipmentByIdProvider(shipment.id!));
                          },
                  ),
                ),

                // const Gap(AppSpaces.small),
                if (justAssigned) const Gap(AppSpaces.small),

                if (justAssigned)
                  Expanded(
                    child: OutlinedCustomButton(
                      isLoading: Loading2,
                      label: 'تأكيد الإستلام',
                      onPressed: () async {
                        setState(() {
                          Loading2 = true;
                        });
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
                                  fromWarehouse: true,
                                ),
                              ),
                            );
                          },
                        );
                        ref.invalidate(
                            getShipmentByIdProvider(widget.shipmentId));

                        setState(() {
                          Loading2 = false;
                        });
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

  Future<void> scanAndNavigateToOrderDetails({
    required BuildContext context,
    required WidgetRef ref,
    required Shipment shipment,
    required void Function(bool) setLoadingState,
  }) async {
    try {
      setLoadingState(true);

      // Step 1: Open scanner screen
      final code = await context.push<String>(
        AppRoutes.scannerScreen,
        extra: ScannerArgs(
          getValue: true,
          totalCount: shipment.orders?.length ?? 0,
        ),
      );

      // Step 2: If user cancelled scanner
      if (code == null) {
        print('❌ Scanner was cancelled or returned null');
        setLoadingState(false);
        return;
      }

      print('📦 Scanned code: $code');

      // Step 3: Fetch order by scanned code
      final orderResult =
          await ref.read(ordersNotifierProvider.notifier).getOrderByCode(
                shipmentId: shipment.id!,
                code: code,
              );

      setLoadingState(false); // Stop loading here (after API call)

      // Step 4: Handle failed lookup
      if (orderResult.$1 == null) {
        GlobalToast.show(
          context: context,
          message: orderResult.$2 ?? 'لم يتم العثور على الطلب',
          backgroundColor: context.colorScheme.error,
        );
        return;
      }

      final order = orderResult.$1!;
      print('✅ Order found: ${order.id}');

      // Step 5: Safely navigate if widget still mounted
      if (!context.mounted) {
        print('⚠️ Widget no longer mounted — skip navigation');
        return;
      }

      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.push(
          AppRoutes.orderDetails,
          extra: OrderDetailsArgs(
            id: orderResult.$1!.id!,
            shipment: shipment,
            isPickup: false,
          ),
        );
      });
    } catch (e, s) {
      setLoadingState(false);
      print('❌ Unexpected error: $e');
      print(s);
      if (context.mounted) {
        GlobalToast.show(
          context: context,
          message: 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً',
          backgroundColor: context.colorScheme.error,
        );
      }
    }
  }

  void _setLoadingState(bool state) {
    return setState(() {
      isLoading = state;
    });
  }
}
