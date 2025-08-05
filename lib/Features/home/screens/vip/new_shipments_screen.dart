import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:Tosell/Features/home/screens/vip/vip_order_screen.dart';
import 'package:Tosell/Features/shipments/widgets/shipment_cart_item.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';
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
      child: ValueListenableBuilder<List<ShipmentInMap>>(
        valueListenable: assignedShipmentsNotifier,
        builder: (context, assignedShipments, child) {
          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            itemCount: assignedShipments.length,
            itemBuilder: (context, index) {
              var shipment = assignedShipments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: buildShipmentCart(
                  context,
                  shipmentInMap: shipment,
                ),
              );
            },
          );
        },
      ),
    ));
  }
}

Widget buildShipmentCart(BuildContext context,
    {required ShipmentInMap shipmentInMap}) {
  bool isPickup = shipmentInMap.type == 0;
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with code and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      shipmentInMap.code ?? 'لايوجد',
                      style: context.textTheme.titleMedium!.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isPickup ? Icons.upload : Icons.download,
                    color: context.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
              buildShipmentStatus(shipmentInMap.status!, shipmentInMap.type!),
            ],
          ),

          const SizedBox(height: 16),

          // Location info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff698596).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: const Color(0xff698596),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPickup ? 'نقطة الإستحصال' : 'نقطة التوصيل',
                      style: context.textTheme.titleSmall!.copyWith(
                        fontSize: 14,
                        color: context.colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPickup
                          ? '${shipmentInMap.pickUpZone?.name ?? ''} - ${shipmentInMap.pickUpZone?.governorate?.name ?? ''}'
                          : '${shipmentInMap.deliveryZone?.name ?? ''} - ${shipmentInMap.deliveryZone?.governorate?.name ?? ''}',
                      style: context.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: FillButton(
                  label: 'تفاصيل الطلب',
                  borderRadius: 12,
                  height: 44,
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedCustomButton(
                  borderColor: context.colorScheme.primary,
                  textColor: context.colorScheme.primary,
                  borderRadius: 12,
                  height: 44,
                  label: 'عرض المسار',
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
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
