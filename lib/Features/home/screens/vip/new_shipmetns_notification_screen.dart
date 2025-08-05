import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:Tosell/Features/home/screens/vip/new_map_screen.dart';
import 'package:Tosell/Features/order/screens/order_details_screen.dart';
import 'package:Tosell/Features/shipments/providers/shipments_provider.dart';
import 'package:Tosell/Features/shipments/widgets/order_card_item.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/OutlineButton.dart';
import 'package:Tosell/core/helpers/contact_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Updated OrdersScreen to use filter and refresh automatically without pull-to-refresh UI

class NewShipmentsNotificationScreen extends ConsumerStatefulWidget {
  const NewShipmentsNotificationScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewShipmentsNotificationScreenState();
}

class _NewShipmentsNotificationScreenState
    extends ConsumerState<NewShipmentsNotificationScreen> {
  List<bool> isLoading = [];

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
    ShipmentDataManager.forceRefreshShipments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(5),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CustomAppBar(
                  title: 'إشعارات الطلبات الجديدة',
                  showBackButton: true,
                ),
              ),
              _buildUi(),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildUi() {
    return Expanded(
      child: ValueListenableBuilder<List<ShipmentInMap>>(
        valueListenable: unAssignedShipmentsNotifier,
        builder: (context, unAssignedShipments, child) {
          if (isLoading.length != unAssignedShipments.length) {
            isLoading = List.generate(unAssignedShipments.length, (_) => false);
          }

          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            itemCount: unAssignedShipments.length,
            itemBuilder: (context, index) {
              var shipment = unAssignedShipments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: buildShipmentNotificationCart(
                  context,
                  shipment: shipment,
                  ref: ref,
                  index: index,
                  isLoading: isLoading[index],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildShipmentNotificationCart(
    BuildContext context, {
    required ShipmentInMap shipment,
    required WidgetRef ref,
    required int index,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/notification-01.svg',
                    color: context.colorScheme.primary,
                  ),
                  const Gap(7),
                  Text(
                    'وصل طلب جديد، يلا نتحرك',
                    style: context.textTheme.titleMedium!.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Gap(10.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colorScheme.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildAvatar(
                      context,
                      title: 'عنوان الإستحصال',
                      subtitle:
                          '${shipment.pickUpZone?.name} ${shipment.pickUpZone?.governorate?.name}',
                      icon: '',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3, right: 22),
                      child: SvgPicture.asset(
                        'assets/svg/Line 1.svg',
                        color: context.colorScheme.primary,
                      ),
                    ),
                    buildAvatar(
                      context,
                      title: 'عنوان التوصيل',
                      subtitle:
                          '${shipment.deliveryZone?.name} ${shipment.deliveryZone?.governorate?.name} ',
                      icon: '',
                    ),
                    Gap(10.h),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FillButton(
                  width: 150.w,
                  isLoading: isLoading,
                  label: 'قبول الطلب',
                  borderRadius: 8,
                  onPressed: () async {
                    _setLoadingState(true, index: index);
                    await ref
                        .watch(shipmentsNotifierProvider.notifier)
                        .assign(shipmentId: shipment.id ?? '');
                    _setLoadingState(false, index: index);
                    // طلب تحديث الطلبات بعد قبول الطلب
                    ShipmentDataManager.immediateRefreshShipments();
                  },
                ),
                OutlinedCustomButton(
                  width: 150.w,
                  borderColor: context.colorScheme.onSurface,
                  textColor: context.colorScheme.onSurface,
                  borderRadius: 8,
                  label: 'تحديد المسار',
                  onPressed: () async {
                    try {
                      // فتح Waze مع موقع الاستحصال
                      if (shipment.pickUpLocation != null) {
                        print('🚀 الضغط على زر عرض المسار - موقع الاستحصال');
                        await ContactUtils.openInWaze(shipment.pickUpLocation!);
                      } else {
                        print('❌ لا يوجد موقع استحصال متاح');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('لا يوجد موقع متاح لعرض المسار'),
                            backgroundColor: Colors.red,
                          ),
                        );
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
            ),
          ],
        ),
      ),
    );
  }

  void _setLoadingState(bool state, {int index = 0}) {
    return setState(() {
      isLoading[index] = state;
    });
  }
}

Padding buildAvatar(BuildContext context,
    {required String title, required String subtitle, required String icon}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: CustomAppBar(
      padding: const EdgeInsets.only(),
      title: title,
      titleStyle: context.textTheme.titleSmall!.copyWith(
        fontSize: 14,
        color: context.colorScheme.secondary,
      ),
      showBackButton: false,
      subtitle: subtitle,
      subTitleStyle: context.textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.w500,
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
  );
}
