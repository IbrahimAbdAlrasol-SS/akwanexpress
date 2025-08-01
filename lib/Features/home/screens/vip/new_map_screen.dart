import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:Tosell/Features/home/screens/vip/vip_order_screen.dart';
import 'package:Tosell/Features/order/screens/order_details_screen.dart';
import 'package:Tosell/Features/shipments/providers/shipments_provider.dart';
import 'package:Tosell/Features/shipments/widgets/order_card_item.dart';
import 'package:Tosell/Features/shipments/widgets/shipment_cart_item.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/helpers/contact_utils.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/OutlineButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class NewMapScreenArgs {
  final double? orderLang;
  final double? orderLat;

  const NewMapScreenArgs({this.orderLang, this.orderLat});
}

class NewMapScreen extends ConsumerStatefulWidget {
  final NewMapScreenArgs args;
  final MapController? mapController;
  const NewMapScreen({super.key, required this.args, this.mapController});

  @override
  ConsumerState<NewMapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<NewMapScreen> {
  late bool isAssigned = false;
  bool isLoading = false;
  bool hasCentered = false;
  // bool inTheWay = false;
  bool isPickup = false;

  late ShipmentInMap? selectedShipment;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();

    // Set initial shipment
    selectedShipment = assignedShipmentsNotifier.value.firstOrNull ??
        unAssignedShipmentsNotifier.value.firstOrNull;

    // Post-frame callback ensures FlutterMap is rendered first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryCenterMap(selectedShipment?.pickUpLocation);
    });

    assignedShipmentsNotifier.addListener(_handleAssignedChange);
    unAssignedShipmentsNotifier.addListener(_handleUnassignedChange);
  }

  void _handleAssignedChange() {
    if (!mounted) return;

    final assigned = assignedShipmentsNotifier.value;
    if (assigned.isNotEmpty) {
      selectedShipment = assigned.first;
      _tryCenterMap(assigned.first.pickUpLocation);
    } else {
      final unassigned = unAssignedShipmentsNotifier.value;
      selectedShipment = unassigned.firstOrNull;
      _tryCenterMap(unassigned.firstOrNull?.pickUpLocation);
    }

    initializesValues();
    if (mounted) setState(() {});
  }

  void _handleUnassignedChange() {
    if (!mounted) return;
    final assigned = assignedShipmentsNotifier.value;
    final unassigned = unAssignedShipmentsNotifier.value;
    if (assigned.isEmpty) {
      // final unassigned = unAssignedShipmentsNotifier.value;
      selectedShipment = unassigned.firstOrNull;
      _tryCenterMap(unassigned.firstOrNull?.pickUpLocation);
      initializesValues();

      if (mounted) setState(() {});
    }
  }

  void initializesValues() {
    // inTheWay = (selectedShipment?.status == 2 ||
    //     selectedShipment?.status == 3 ||
    //     selectedShipment?.status == 1);
    isPickup = selectedShipment?.isPickup ?? false;
  }

  void _tryCenterMap(Location? location) {
    if (!hasCentered &&
        location?.lat != null &&
        location?.long != null &&
        selectedShipment != null &&
        mounted) {
      _mapController.move(LatLng(location!.lat!, location.long!), 15.0);
      hasCentered = true;
    }
  }

  @override
  void dispose() {
    assignedShipmentsNotifier.removeListener(_handleAssignedChange);
    unAssignedShipmentsNotifier.removeListener(_handleUnassignedChange);
    super.dispose();
  }

  _setLoadingState(bool state) {
    if (mounted) {
      setState(() {
        isLoading = state;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocationValue = currentLocationNotifier.value;

    final currentLocationMarker = currentLocationValue != null
        ? Marker(
            width: 40,
            height: 40,
            point: LatLng(
              currentLocationValue.latitude,
              currentLocationValue.longitude,
            ),
            child: Transform.rotate(
              angle: (currentLocationValue.heading) *
                  (3.1415926 / 180), // degrees to radians
              child: SvgPicture.asset(
                'assets/svg/car-top-view-icon.svg',
                color: context.colorScheme.primary,
                width: 30,
                height: 30,
              ),
            ),
          )
        : null;

    final allMarkers = [
      if (currentLocationMarker != null) currentLocationMarker,
      ...assignedShipmentsNotifier.value.map((shipment) {
        return Marker(
          width: 40,
          height: 40,
          point: LatLng(
            shipment.deliveryLocation?.lat ?? 0.0,
            shipment.deliveryLocation?.long ?? 0.0,
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                // selectedShipment = shipment;
              });
            },
            child: Tooltip(
              message: "📦 ${shipment.merchantName ?? 'Unknown'}",
              child: const Icon(
                Icons.location_on,
                size: 40,
                color: Colors.orange,
              ),
            ),
          ),
        );
      }),
    ];

    isAssigned = assignedShipmentsNotifier.value.contains(selectedShipment);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ValueListenableBuilder(
                valueListenable: assignedShipmentsNotifier,
                builder: (context, nearbyShipments, child) {
                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(
                        widget.args.orderLat ??
                            nearbyShipments.firstOrNull?.pickUp?.lat ??
                            33.3152,
                        widget.args.orderLang ??
                            nearbyShipments.firstOrNull?.pickUp?.long ??
                            44.3661,
                      ),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(markers: allMarkers)
                    ],
                  );
                }),
          ),

          // Positioned.fill(
          //   child: Container(
          //     color: Colors.black.withOpacity(0.2),
          //     // Optional: add content centered in the overlay
          //   ),
          // ),
          //? bottom sheet

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding:
                  const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 24.0),
              child: ValueListenableBuilder(
                valueListenable: assignedShipmentsNotifier,
                builder: (context, assignedShipments, child) {
                  return ValueListenableBuilder(
                    valueListenable: unAssignedShipmentsNotifier,
                    builder: (context, unAssignedShipments, child) {
                      // تحديث selectedShipment بناءً على القيم الجديدة
                      final currentSelectedShipment = assignedShipments.firstOrNull ?? 
                                                     unAssignedShipments.firstOrNull;
                      
                      // تحديث isAssigned بناءً على الطلبات المقبولة
                      final currentIsAssigned = assignedShipments.contains(currentSelectedShipment);
                      
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: currentSelectedShipment == null
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const Gap(30),
                                    SvgPicture.asset(
                                      'assets/svg/package-out-of-stock.svg',
                                      width: 50,
                                    ),
                                    const Gap(20),
                                    Text(
                                      'ماكو طلبات حالياً',
                                      style: context.textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Gap(5),
                                    Text(
                                      'رح توصلك إشعارات أول ما ينزل طلب جديد، خلّيك جاهز',
                                      style: context.textTheme.titleMedium!.copyWith(
                                        color: context.colorScheme.secondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Gap(20),
                                  ],
                                ),
                              )
                            : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (currentSelectedShipment != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, right: 18.0, left: 18.0),
                              child: currentIsAssigned
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          currentSelectedShipment?.code ?? 'لايوجد ',
                                          style: context.textTheme.titleMedium!
                                              .copyWith(
                                            color: context.colorScheme.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        buildShipmentStatus(
                                            currentSelectedShipment!.status!,
                                            currentSelectedShipment!.type!),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.notifications_outlined,
                                              color:
                                                  context.colorScheme.primary,
                                            ),
                                            SizedBox(
                                              width: 5.w,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(
                                                'وصل طلب جديد، يلا نتحرك',
                                                style: context
                                                    .textTheme.titleMedium!
                                                    .copyWith(
                                                  color: context
                                                      .colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '40 دقيقة',
                                          style: context.textTheme.titleMedium!
                                              .copyWith(
                                            color:
                                                context.colorScheme.secondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Divider(
                              color: context.colorScheme.secondary
                                  .withOpacity(0.5),
                            ),
                          ),
                          buildAvatar(
                            context,
                            title: 'نقطة الاستحصال',
                            subtitle:
                                '${currentSelectedShipment?.pickUpZone?.name} ${currentSelectedShipment?.pickUpZone?.governorate?.name}',
                            icon: '',
                          ),
                          if (!currentIsAssigned)
                            Wrap(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 3, right: 22),
                                  child:
                                      SvgPicture.asset('assets/svg/Line 1.svg'),
                                ),
                                buildAvatar(
                                  context,
                                  title: 'نقطة التوصيل',
                                  subtitle:
                                      '${currentSelectedShipment?.deliveryZone?.name} ${currentSelectedShipment?.deliveryZone?.governorate?.name} ',
                                  icon: '',
                                ),
                              ],
                            ),
                          const Gap(AppSpaces.small),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 150.w,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentIsAssigned 
                                        ? context.colorScheme.primary  // لون البرايمري لتفاصيل الطلب
                                        : const Color(0xFF24A870),      // أخضر لقبول الطلب
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : currentIsAssigned
                                          ? () {
                                              _setLoadingState(true);
                                              context.push(
                                                AppRoutes.vipOrder,
                                                extra: VipOrderArgs(
                                                  id: currentSelectedShipment
                                                          ?.order?.id ??
                                                      '',
                                                  shipmentId:
                                                      currentSelectedShipment?.id ??
                                                          '',
                                                  isPickup: currentSelectedShipment?.isPickup ?? false,
                                                ),
                                              );
                                              _setLoadingState(false);
                                            }
                                          : () async {
                                              _setLoadingState(true);
                                              var result = await ref
                                                  .read(
                                                      shipmentsNotifierProvider
                                                          .notifier)
                                                  .assign(
                                                      shipmentId:
                                                          currentSelectedShipment
                                                                  ?.id ??
                                                              '');
                                              _setLoadingState(false);
                                              if (result.$1 != null) {
                                                if (mounted) {
                                                  setState(() {
                                                    isAssigned = true;
                                                  });
                                                }
                                                GlobalToast.show(
                                                  context: context,
                                                  message: "تم تحديث الحالة",
                                                  backgroundColor: context
                                                      .colorScheme.primary,
                                                  textColor: Colors.white,
                                                );
                                              } else {
                                                GlobalToast.show(
                                                  context: context,
                                                  message: result.$2 ??
                                                      'حدث خطأ في قبول الطلبية ',
                                                  backgroundColor:
                                                      context.colorScheme.error,
                                                  textColor: Colors.white,
                                                );
                                              }
                                            },
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Text(
                                          currentIsAssigned ? 'تفاصيل الطلب' : 'قبول',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              Container(
                                width: 150.w,
                                height: 48,           
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: context.colorScheme.onSurface),
                                    foregroundColor:
                                        context.colorScheme.onSurface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    try {
                                      final currentIsPickup = currentSelectedShipment?.isPickup ?? false;
                                      if (currentIsPickup) {
                                        if (currentSelectedShipment?.pickUpLocation !=
                                            null) {
                                          print(
                                              '🚀 الضغط على زر عرض المسار - موقع الاستحصال');
                                          await ContactUtils.openInWaze(
                                              currentSelectedShipment!
                                                  .pickUpLocation!);
                                        } else {
                                          print('❌ لا يوجد موقع استحصال متاح');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'لا يوجد موقع استحصال متاح'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        if (currentSelectedShipment
                                                ?.deliveryLocation !=
                                            null) {
                                          print(
                                              '🚀 الضغط على زر عرض المسار - موقع التوصيل');
                                          await ContactUtils.openInWaze(
                                              currentSelectedShipment!
                                                  .deliveryLocation!);
                                        } else {
                                          print('❌ لا يوجد موقع توصيل متاح');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'لا يوجد موقع توصيل متاح'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      print('❌ خطأ في فتح المسار: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('فشل في فتح تطبيق الخرائط'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/svg/map.svg',
                                    width: 20,
                                    height: 20,
                                    color: context.colorScheme.onSurface,
                                  ),
                                  label: Text(
                                    'عرض مسار',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: context.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(AppSpaces.medium),
                        ],
                      ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
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
        )),
  );
}
