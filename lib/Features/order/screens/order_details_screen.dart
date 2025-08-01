import 'package:Tosell/Features/changeState/screens/otp_dialog.dart';
import 'package:Tosell/Features/changeState/screens/scanner_screen.dart';
import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:Tosell/Features/home/screens/vip/delay_or_return_dialog.dart';
import 'package:Tosell/Features/home/screens/vip/vip_order_screen.dart';
import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:Tosell/Features/shipments/providers/orders_provider.dart';
import 'package:Tosell/Features/shipments/providers/shipments_provider.dart';
import 'package:Tosell/Features/support/providers/ticket_provider.dart';
import 'package:Tosell/Features/support/screens/add_ticket_dailog.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/core/widgets/custom_section.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';
import 'package:Tosell/Features/order/providers/order_commands_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailsArgs {
  String id;
  Shipment shipment;
  bool isPickup;
  OrderDetailsArgs(
      {required this.id, required this.shipment, required this.isPickup});
}

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final OrderDetailsArgs args;
  const OrderDetailsScreen({super.key, required this.args});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  bool isLoading = false;
  int handelProductState(int state) {
    return state;
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync =
        ref.watch(getOrderByIdAndShipmentIdProvider(widget.args));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: orderAsync.when(
        data: (order) => buildUi(context, order),
        error: (error, stack) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget buildUi(BuildContext context, Order? order) {
    if (order == null) {
      return const Center(child: Text('لايوجد طلب بهذا الكود '));
    }
    var isPickup = widget.args.isPickup;

    return Column(
      key: Key(order.hashCode.toString()),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CustomAppBar(
                        title: "تفاصيل الطلب",
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
                              .createOrderTicket(
                                  orderId: order.id!, description: description);

                          if (result?.singleData == null) {
                            GlobalToast.show(
                              context: context,
                              backgroundColor: context.colorScheme.error,
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
              buildUserInfo(
                context,
                order,
                isCustomer: true,
              ),
              buildInvoice(context, order),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: context.colorScheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                const Gap(AppSpaces.small),
                FillButton(
                  isLoading: isLoading,
                  label:
                      isPickup ? 'تأكيد الاستلام - QR' : 'تأكيد التسليم - QR',
                  onPressed: () async {
                    _setLoadingState(true);
                    var code = await context.push<String>(
                      AppRoutes.scannerScreen,
                      extra: ScannerArgs(
                        getValue: true,
                      ),
                    );

                    if (code == null) return;
                    var orderResult = (await ref
                        .read(ordersNotifierProvider.notifier)
                        .getOrderByCode(
                            shipmentId: widget.args.shipment.id ?? '',
                            code: code));

                    if (orderResult.$1 == null) {
                      GlobalToast.show(
                        context: context,
                        backgroundColor: context.colorScheme.error,
                        message: orderResult.$2 ?? "unknown error",
                      );
                    }
                    if (!isPickup) {
                      var orderResult = await ref
                          .read(ordersNotifierProvider.notifier)
                          .delivered(
                              orderId: widget.args.id,
                              shipmentId: widget.args.shipment.id!);
                      if (orderResult.$1 == null) {
                        GlobalToast.show(
                          context: context,
                          message: orderResult.$2!,
                          backgroundColor: context.colorScheme.error,
                        );
                      } else if (orderResult.$1!.hasOtp!) {
                        showDialog(
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
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.zero,
                                  child: OtpDialog(
                                    args: OtpDialogArgs(
                                      order: order,
                                      shipmentId: widget.args.shipment.id ?? '',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        GlobalToast.show(
                          context: context,
                          message: 'تم تحديث حالة الطلب',
                          backgroundColor: Colors.green,
                        );
                        if (context.mounted) {
                          context.go(AppRoutes.shipments);
                        }
                      }
                      _invalidateRequests();
                    } else {
                      (dynamic, String?)? result;
                      {
                        result = await ref
                            .read(ordersNotifierProvider.notifier)
                            .receivedOrder(
                              isVip: false,
                              code: orderResult.$1!.code!,
                              shipmentId: widget.args.shipment.id ?? '',
                            );
                      }
                      if (result.$1 != null) {
                        GlobalToast.show(
                          context: context,
                          backgroundColor: Colors.green,
                          message: 'تم استلام الطلب بنجاح',
                        );
                        _invalidateRequests();

                        if (context.mounted) {
                          context.go(AppRoutes.shipments);
                        }
                      } else {
                        _setLoadingState(false);

                        GlobalToast.show(
                          context: context,
                          backgroundColor: context.colorScheme.error,
                          message: result.$2 ?? "unknown error",
                        );
                      }
                    }
                    _setLoadingState(false);
                  },
                ),
                const Gap(AppSpaces.exSmall),
                FillButton(
                  label: 'مؤجل / راجع',
                  color: context.colorScheme.error,
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          insetPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 24),
                          child: IntrinsicHeight(
                            child: SingleChildScrollView(
                              child: DelayOrReturnDialog(
                                orderId: widget.args.id,
                                shipmentId: widget.args.shipment.id ?? '',
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const Gap(AppSpaces.medium),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _invalidateRequests() {
    ref.invalidate(getOrderByIdAndShipmentIdProvider(widget.args));
    ref.invalidate(getShipmentByIdProvider(widget.args.shipment.id ?? ''));
  }

  void _setLoadingState(bool state) {
    return setState(() {
      isLoading = state;
    });
  }

  GestureDetector _buildMap(BuildContext context, {Location? location}) {
    final lat = location?.lat ?? 30.0;
    final long = location?.long ?? 8.0;

    return GestureDetector(
      onTap: () async {
        final url = Uri.parse('waze://?ll=$lat,$long&navigate=yes');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          // fallback: open Waze in browser
          final webUrl =
              Uri.parse('https://waze.com/ul?ll=$lat,$long&navigate=yes');
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/map.png',
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 3),
                    child: SvgPicture.asset(
                      'assets/svg/MapPinLine.svg',
                      color: context.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'عرض الموقع',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  CustomSection buildProductInfo(BuildContext context,
      {required String content}) {
    return CustomSection(
      title: "معلومات المنتج",
      icon: SvgPicture.asset(
        "assets/svg/box.svg",
        color: Theme.of(context).colorScheme.primary,
      ),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      childrenRadius: const BorderRadius.all(Radius.circular(16)),
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildOrderSection(
                title: "تفاصيل المنتج",
                iconPath: "assets/svg/Cards.svg",
                Theme.of(context),
                padding: const EdgeInsets.only(bottom: 3, top: 3),
                subWidget: Text(content),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildOrderState(BuildContext context, OrderEnum state, int index) {
  //   return GestureDetector(
  //     onTap: () => showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       // Remove isScrollControlled or keep it only if you really need scrolling
  //       builder: (BuildContext context) {
  //         return SizedBox(
  //           height: 660,
  //           child: OrderStateBottomSheet(
  //             state: index,
  //           ),
  //         );
  //       },
  //     ),
  //     child: CustomSection(
  //       title: "حالة الطلب",
  //       icon: SvgPicture.asset(
  //         'assets/svg/ArrowsDownUp.svg',
  //         color: Theme.of(context).colorScheme.primary,
  //       ),
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8),
  //           child: Row(
  //             children: [
  //               Container(
  //                 width: 50,
  //                 height: 50,
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   shape: BoxShape.circle,
  //                   border: Border.all(
  //                     color: Theme.of(context).colorScheme.outline,
  //                   ),
  //                 ),
  //                 child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: SvgPicture.asset(
  //                       state.icon!,
  //                       color: context.colorScheme.primary,
  //                     )),
  //               ),
  //               const SizedBox(width: 10),
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     state.name!,
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w800,
  //                       color: context.colorScheme.primary,
  //                       fontFamily: "Tajawal",
  //                     ),
  //                   ),
  //                   Text(
  //                     state.description!,
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.w400,
  //                       color: Theme.of(context).colorScheme.onSurface,
  //                       fontFamily: "Tajawal",
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

Widget buildOrderSection(
  ThemeData theme, {
  String? title,
  double? height,
  String? iconPath,
  void Function()? onTap,
  EdgeInsets? padding,
  double? iconHight,
  double? iconWidth,
  Widget? subWidget,
}) {
  return SizedBox(
    height: height,
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            if (iconPath != null)
              Padding(
                padding: const EdgeInsets.all(3),
                child: SvgPicture.asset(
                  iconPath,
                  width: iconWidth ?? 24,
                  height: iconHight ?? 24,
                  color: theme.colorScheme.primary,
                ),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.secondary,
                        fontFamily: "Tajawal",
                      ),
                    ),
                  if (subWidget != null) subWidget
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
