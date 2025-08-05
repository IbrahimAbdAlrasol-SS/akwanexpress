import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:Tosell/Features/home/screens/vip/custom_segmented_tabs.dart';
import 'package:Tosell/Features/home/screens/vip/new_map_screen.dart';
import 'package:Tosell/Features/home/screens/vip/new_shipments_screen.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class VipHomeScreen extends StatefulWidget {
  const VipHomeScreen({super.key});

  @override
  State<VipHomeScreen> createState() => _VipHomeScreenState();
}

class _VipHomeScreenState extends State<VipHomeScreen> {
  int selectedIndex = 1;
  final MapController _mapController = MapController();
  bool _isLocatingUser = false;

  @override
  void initState() {
    super.initState();
    // طلب الطلبات القريبة عند فتح الشاشة
    _requestNearbyShipments();

    // إضافة مستمع لتغيير الموقع
    currentLocationNotifier.addListener(_handleLocationChange);

    // تحديد الموقع الحالي عند فتح التطبيق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
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

  Future<void> _getCurrentLocation() async {
    if (_isLocatingUser) return;

    setState(() {
      _isLocatingUser = true;
    });

    try {
      // التحقق من تفعيل خدمات الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        setState(() {
          _isLocatingUser = false;
        });
        return;
      }

      // التحقق من الصلاحيات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLocatingUser = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLocatingUser = false;
        });
        return;
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // تحديث الموقع في النوتيفاير
      currentLocationNotifier.value = LocationWithHeading(
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
      );

      // تحريك الخريطة للموقع الحالي إذا كانت الخريطة مفتوحة
      if (selectedIndex == 1 && mounted) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          16.0,
        );
      }
    } catch (e) {
      print('خطأ في تحديد الموقع: $e');
    } finally {
      setState(() {
        _isLocatingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND: switchable screen behind tabs
          Positioned.fill(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                const NewShipmentsScreen(),
                NewMapScreen(
                  args: const NewMapScreenArgs(),
                  mapController: _mapController,
                ),
              ],
            ),
          ),

          // FIXED SEGMENTED TABS ON TOP
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomSegmentedTabs(
                  selectedIndex: selectedIndex,
                  onTabSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),

          // زر تحديد الموقع الحالي
          if (selectedIndex == 1) // يظهر فقط في صفحة الخريطة
            Positioned(
              top: 120, // في أعلى الشاشة تحت التابز
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _getCurrentLocation,
                    child: Container(
                      width: 56,
                      height: 56,
                      padding: const EdgeInsets.all(16),
                      child: _isLocatingUser
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1976D2),
                              ),
                            )
                          : Icon(
                              Icons.my_location,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
