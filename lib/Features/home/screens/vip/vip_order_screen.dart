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
import 'package:Tosell/core/helpers/hubMethods.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/OutlineButton.dart';
import 'package:Tosell/core/widgets/custom_section.dart';
import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
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
  void initState() {
    super.initState();
    // طلب الطلبات القريبة عند فتح الشاشة
    _requestNearbyShipments();

    // إضافة مستمع لتغيير الموقع
    currentLocationNotifier.addListener(_handleLocationChange);
  }

  @override
  void dispose() {
    // إزالة المستمع عند إغلاق الشاشة
    currentLocationNotifier.removeListener(_handleLocationChange);
    super.dispose();
  }

  void _requestNearbyShipments() {
    invokeNearbyShipment();
  }

  void _handleLocationChange() {
    _requestNearbyShipments();
  }

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
            // شريط علوي مع زر الرجوع وزر التواصل مع الدعم
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر الرجوع
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: context.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    // زر التواصل مع الدعم
                    GestureDetector(
                      onTap: () {
                        // فتح الواتساب للتواصل مع الدعم
                        ContactUtils.openWhatsApp(
                            '+9647700000000'); // رقم الدعم
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.support_agent,
                              color: context.colorScheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'الدعم',
                              style: TextStyle(
                                color: context.colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // كرد معلومات الطلب مع padding
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            // كرد معلومات التاجر/الزبون مع padding وتكبير الطول
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
              child: buildUserInfo(context, order, isCustomer: !isPickup),
            ),
            if (!isPickup)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
                child: buildInvoice(context, order),
              ),
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
                      // طلب تحديث الطلبات بعد تحديث الحالة
                      _requestNearbyShipments();
                    }
                  },
                )
              : SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
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
                            ).then((result) {
                              // طلب تحديث الطلبات بعد إغلاق الحوار
                              if (result != null) {
                                _requestNearbyShipments();
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
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
                            ).then((result) {
                              // طلب تحديث الطلبات بعد إغلاق الحوار
                              if (result != null) {
                                _requestNearbyShipments();
                              }
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
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
            const Gap(AppSpaces.medium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: OutlinedCustomButton(
                    label: '',
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
                        ? () async {
                            try {
                              await ContactUtils.makeCall(
                                  order.customerPhoneNumber ?? '');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في الاتصال: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : () async {
                            try {
                              await ContactUtils.makeCall(
                                  order.merchant?.phoneNumber ?? '');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في الاتصال: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedCustomButton(
                    label: '',
                    fontSize: 12,
                    textColor: const Color(0xff33CC34),
                    borderRadius: 16,
                    borderColor: const Color(0xff33CC34),
                    reverse: true,
                    icon: SvgPicture.asset(
                      'assets/svg/social-whats-app-svgrepo-com.svg',
                      color: const Color(0xff33CC34),
                      height: 20,
                    ),
                    onPressed: isCustomer
                        ? () async {
                            try {
                              await ContactUtils.openWhatsApp(
                                  order.customerPhoneNumber ?? '');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في فتح الواتساب: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        : () async {
                            try {
                              await ContactUtils.openWhatsApp(
                                  order.merchant?.phoneNumber ?? '');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في فتح الواتساب: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedCustomButton(
                    label: '',
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
                            print(
                                '🚀 الضغط على زر المسار - موقع التوصيل للزبون');
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
                                '� الضغط على زر المسار - موقع الاستحصال للتاجر');
                            await ContactUtils.openInWaze(
                                order.pickupLocation!);
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
                ),
              ],
            ),
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
