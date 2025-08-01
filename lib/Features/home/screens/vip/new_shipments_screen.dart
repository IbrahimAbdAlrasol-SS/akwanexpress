import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:Tosell/Features/home/screens/vip/vip_order_screen.dart';
import 'package:Tosell/Features/shipments/widgets/shipment_cart_item.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/OutlineButton.dart';
import 'package:Tosell/core/helpers/contact_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Updated OrdersScreen to use filter and refresh automatically without pull-to-refresh UI

class NewShipmentsScreen extends ConsumerStatefulWidget {
  const NewShipmentsScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewShipmentsScreenState();
}

class _NewShipmentsScreenState extends ConsumerState<NewShipmentsScreen> {
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
              _buildUi(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUi() {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 50),
      child: ListView.builder(
        itemCount: assignedShipmentsNotifier.value.length,
        itemBuilder: (context, index) {
          var shipment = assignedShipmentsNotifier.value[index];
          return buildShipmentCart(
            context,
            shipmentInMap: shipment,
          );
        },
      ),
    ));
  }
}

Widget buildShipmentCart(BuildContext context,
    {required ShipmentInMap shipmentInMap}) {
  bool isPickup = shipmentInMap.type == 0;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                shipmentInMap.code ?? 'لايوجد ',
                style: context.textTheme.titleMedium!.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            buildShipmentStatus(shipmentInMap.status!,
                shipmentInMap.type!), //TODO : Fix it later
          ],
        ),
        CustomAppBar(
          padding: const EdgeInsets.only(right: 12),
          title: isPickup ? 'نقطة الإستحصال' : 'نقطة التوصيل',
          titleStyle: context.textTheme.titleSmall!.copyWith(
            fontSize: 14,
            color: context.colorScheme.secondary,
          ),
          showBackButton: false,
          subtitle: isPickup
              ? '${shipmentInMap.pickUpZone?.name} ${shipmentInMap.pickUpZone?.governorate?.name} '
              : '${shipmentInMap.deliveryZone?.name} ${shipmentInMap.deliveryZone?.governorate?.name} ',
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
        Gap(10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FillButton(
              width: 150.w,
              label: 'تفاصيل الطلب',
              borderRadius: 8,
              onPressed: () {
                context.push(
                  AppRoutes.vipOrder,
                  extra: VipOrderArgs(
                      id: shipmentInMap.order?.id ?? '',
                      shipmentId: shipmentInMap.id ?? '',
                      isPickup: isPickup),
                );
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
                  // فتح Waze مع الموقع المناسب حسب نوع الطلب
                  if (isPickup && shipmentInMap.pickUpLocation != null) {
                    print('🚀 الضغط على زر عرض المسار - موقع الاستحصال');
                    await ContactUtils.openInWaze(
                        shipmentInMap.pickUpLocation!);
                  } else if (!isPickup &&
                      shipmentInMap.deliveryLocation != null) {
                    print('🚀 الضغط على زر عرض المسار - موقع التوصيل');
                    await ContactUtils.openInWaze(
                        shipmentInMap.deliveryLocation!);
                  } else {
                    print('❌ لا يوجد موقع متاح');
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
  );
}
