import 'package:Tosell/Features/changeState/screens/otp_dialog.dart';
import 'package:Tosell/Features/home/screens/vip/delay_or_return_dialog.dart';
import 'package:Tosell/Features/home/screens/vip/new_upload_iamges_dialog.dart';
import 'package:Tosell/Features/order/providers/order_commands_provider.dart';
import 'package:Tosell/Features/order/screens/order_details_screen.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';
import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:Tosell/Features/shipments/providers/orders_provider.dart';
import 'package:Tosell/Features/shipments/widgets/order_card_item.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/helpers/contact_utils.dart';
import 'package:Tosell/core/helpers/formater.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/OutlineButton.dart';
import 'package:Tosell/core/widgets/custom_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VipOrderArgs {
  final String id;
  final String shipmentId;
  final bool isPickup;

  const VipOrderArgs({
    required this.id,
    required this.shipmentId,
    this.isPickup = false,
  });
}

class VipOrderScreen extends ConsumerStatefulWidget {
  final VipOrderArgs args;
  const VipOrderScreen({super.key, required this.args});

  @override
  ConsumerState<VipOrderScreen> createState() => _VipOrderScreenState();
}

class _VipOrderScreenState extends ConsumerState<VipOrderScreen> {
  var buttonWidth = 100.0;
  // late bool atPoint = true;
  late bool isPickup = false;
  bool isLoading = false;
  bool hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    final orderAsync =
        ref.watch(getOrderByIdAndShipmentIdVipProvider(widget.args));

    return Scaffold(
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(
              child: Text('order not found'),
            );
          }
          return buildUi(context, order);
        },
        error: (error, stack) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget buildUi(BuildContext context, Order order) {
    if (!hasInitialized) {
      isPickup = (order.status == 2 || order.status == 3);
      hasInitialized = true;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              child: CustomSection(
                title: "معلومات الطلب",
                icon: SvgPicture.asset(
                  "assets/svg/Receipt.svg",
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                childrenRadius: const BorderRadius.all(Radius.circular(16)),
                children: [
                  IntrinsicHeight(
                    child: buildOrderSection(
                      title: "رقم الطلب",
                      Theme.of(context),
                      padding: const EdgeInsets.only(bottom: 3, top: 3),
                      subWidget: Text(order.code ?? 'لايوجد'),
                    ),
                  ),
                  IntrinsicHeight(
                    child: buildOrderSection(
                      title: "تاريخ الطلب",
                      Theme.of(context),
                      padding: const EdgeInsets.only(bottom: 3, top: 3),
                      subWidget: Text(order.creationDate.toString()),
                    ),
                  ),
                  IntrinsicHeight(
                    child: buildOrderSection(
                      title: "حالة الطلب",
                      Theme.of(context),
                      padding: const EdgeInsets.only(bottom: 3, top: 3),
                      subWidget: buildOrderStatus(order.status!),
                    ),
                  ),
                ],
              ),
            ),
            buildUserInfo(context, order, isCustomer: !isPickup),
            if (!isPickup) buildInvoice(context, order),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: isPickup
              ? FillButton(
                  isLoading: isLoading,
                  label: 'التقاط صورة للمنتج',
                  borderRadius: 16,
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        insetPadding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: NewUploadImagesDialog(
                          args: NewUploadImagesArgs(
                            shipmentId: widget.args.shipmentId,
                          ),
                        ),
                      ),
                    );
                    if (result != null && mounted) {
                      setState(() {
                        isPickup = false;
                      });
                    }
                  },
                )
              : Row(
                  children: [
                    Expanded(
                      child: FillButton(
                        label: 'تم التسليم',
                        borderRadius: 16,
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
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minWidth: double.infinity,
                                  ),
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.zero,
                                    child: OtpDialog(
                                      args: OtpDialogArgs(
                                        order: order,
                                        shipmentId: widget.args.shipmentId,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                          // showDialog(
                          //   context: context,
                          //   barrierDismissible: false,
                          //   builder: (context) => Dialog(
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(16),
                          //     ),
                          //     insetPadding:
                          //         const EdgeInsets.symmetric(horizontal: 24),
                          //     child: OtpDialog(
                          //       args: OtpDialogArgs(
                          //         order: order,
                          //         shipmentId: widget.args.shipmentId,
                          //       ),
                          //     ),
                          //   ),
                          // );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedCustomButton(
                        label: 'مؤجل / راجع',
                        borderRadius: 16,
                        borderColor: context.colorScheme.error,
                        textColor: context.colorScheme.error,
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
                                      shipmentId: widget.args.shipmentId,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                          // showDialog(
                          //   context: context,
                          //   barrierDismissible: false,
                          //   builder: (context) => DelayOrReturnDialog(
                          //     orderId: order.id ?? '',
                          //     shipmentId: widget.args.shipmentId,
                          //   ),
                          // );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

CustomSection buildUserInfo(BuildContext context, Order order,
    {bool isCustomer = false, Shipment? shipment}) {
  return CustomSection(
    title: isCustomer ? "معلومات الزبون" : 'معلومات التاجر',
    icon: SvgPicture.asset(
      "assets/svg/User.svg",
      color: Theme.of(context).colorScheme.primary,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(16)),
    childrenRadius: const BorderRadius.all(Radius.circular(16)),
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
        child: Column(
          children: [
            CustomAppBar(
              padding: const EdgeInsets.only(),
              title: isCustomer
                  ? '${order.deliveryZone?.name} , ${order.deliveryZone?.governorate?.name}'
                  : '${order.pickupZone?.name} , ${order.pickupZone?.governorate?.name}',
              titleStyle: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w500,
              ),
              showBackButton: false,
              subtitle: isCustomer
                  ? order.customerName
                  : order.merchant?.brandName ?? 'لايوجد',
              secondSubtitle: isCustomer
                  ? order.customerPhoneNumber
                  : order.merchant?.phoneNumber,
              subTitleStyle: context.textTheme.titleSmall!.copyWith(
                fontSize: 14,
                color: context.colorScheme.secondary,
              ),
              buttonWidget: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xff698596),
                ),
                width: 40,
                height: 40,
              ),
            ),
            const Gap(AppSpaces.small),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedCustomButton(
                  label: 'هاتف',
                  fontSize: 12,
                  borderRadius: 16,
                  textColor: const Color(0xff034EC9),
                  borderColor: const Color(0xff034EC9),
                  reverse: true,
                  icon: const Icon(
                    Icons.phone,
                    color: Color(0xff034EC9),
                  ),
                  onPressed: isCustomer
                      ? () =>
                          ContactUtils.makeCall(order.customerPhoneNumber ?? '')
                      : () => ContactUtils.makeCall(
                          order.merchant?.phoneNumber ?? ''),
                ),
                OutlinedCustomButton(
                  label: 'واتساب',
                  fontSize: 12,
                  textColor: const Color(0xff33CC34),
                  borderRadius: 16,
                  borderColor: const Color(0xff33CC34),
                  reverse: true,
                  icon: SvgPicture.asset(
                    'assets/svg/social-whats-app-svgrepo-com.svg',
                    color: const Color(0xff33CC34),
                    width: 20,
                  ),
                  onPressed: isCustomer
                      ? () => ContactUtils.openWhatsApp(
                          order.customerPhoneNumber ?? '')
                      : () => ContactUtils.openWhatsApp(
                          order.merchant?.phoneNumber ?? ''),
                ),
                OutlinedCustomButton(
                  label: 'المسار',
                  fontSize: 12,
                  textColor: const Color(0xff21B0F8),
                  borderRadius: 16,
                  borderColor: const Color(0xff21B0F8),
                  reverse: true,
                  icon: SvgPicture.asset(
                    'assets/svg/waze-stroke-rounded.svg',
                    color: const Color(0xff21B0F8),
                  ),
                  onPressed: () async {
                    try {
                      if (isCustomer) {
                        if (order.deliveryLocation != null) {
                          print('🚀 الضغط على زر المسار - موقع التوصيل للزبون');
                          await ContactUtils.openInWaze(
                              order.deliveryLocation!);
                        } else {
                          print('❌ لا يوجد موقع توصيل للزبون');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('لا يوجد موقع توصيل متاح'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        if (order.pickupLocation != null) {
                          print(
                              '🚀 الضغط على زر المسار - موقع الاستحصال للتاجر');
                          await ContactUtils.openInWaze(order.pickupLocation!);
                        } else {
                          print('❌ لا يوجد موقع استحصال للتاجر');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('لا يوجد موقع استحصال متاح'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      print('❌ خطأ في فتح المسار: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('فشل في فتح تطبيق الخرائط'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    ],
  );
}

CustomSection buildInvoice(BuildContext context, Order order) {
  return CustomSection(
    title: 'معلومات الفاتورة',
    icon: SvgPicture.asset(
      "assets/svg/User.svg",
      color: Theme.of(context).colorScheme.primary,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(16)),
    childrenRadius: const BorderRadius.all(Radius.circular(16)),
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            buildPriceRow(
              label: 'سعر الطلب',
              amount: '${formatPrice(order.totalAmount)} د.ع',
              labelStyle: const TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Divider(
                  color: context.colorScheme.secondary.withOpacity(0.5)),
            ),
            buildPriceRow(
              label: 'المجموع الكلي',
              amount: '${formatPrice(order.totalAmount)} د.ع',
              labelStyle: context.textTheme.bodyMedium!.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              amountStyle: const TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget buildPriceRow({
  required String label,
  required String amount,
  TextStyle? labelStyle,
  TextStyle? amountStyle,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: labelStyle ?? const TextStyle(fontSize: 16)),
      Text(amount, style: amountStyle ?? const TextStyle(fontSize: 16)),
    ],
  );
}
