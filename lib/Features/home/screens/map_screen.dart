import 'package:Tosell/Features/home/models/shipment_in_map.dart';
import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:Tosell/Features/home/screens/upload_order_image_section.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';
import 'package:Tosell/Features/shipments/providers/orders_provider.dart';
import 'package:Tosell/Features/shipments/providers/shipments_provider.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
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
import 'package:pin_code_fields/pin_code_fields.dart';

class MapScreenArgs {
  final bool isOrderDetails;
  final double? orderLang;
  final double? orderLat;

  const MapScreenArgs(
      {this.isOrderDetails = false, this.orderLang, this.orderLat});
}

class MapScreen extends ConsumerStatefulWidget {
  final MapScreenArgs args;
  const MapScreen({super.key, required this.args});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  late bool isAccepted;
  // bool isArrived = false;
  bool showAppBar = true;
  bool hasCentered = false;
  late bool atDeliveryPoint;
  late bool atPickUpPoint;
  bool isRefunded = false;
  bool isLoading = false;

  bool isCompleted =
      false; //? for navigation home page after verification of the code
  // ShipmentInMap? selectedShipment = nearbyShipmentsNotifier.value.firstOrNull;

  List<String> attachments = [];
  TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final MapController _mapController;

  @override
  // void initState() {
  //   super.initState();
  //   _mapController = MapController();
  //   Future.microtask(() {
  //     nearbyShipmentsNotifier.addListener(() {
  //       final next = nearbyShipmentsNotifier.value;
  //       selectedShipment = next.firstOrNull;
  //       if (!hasCentered && next.isNotEmpty) {
  //         final first = next.first.pickUp;
  //         if (first?.lat != null && first?.long != null) {
  //           _mapController.move(LatLng(first!.lat!, first.long!), 15.0);
  //           hasCentered = true;
  //         }
  //       }
  //     });
  //   });
  //   isAccepted = !(selectedShipment?.isShipment ?? true);
  //   atDeliveryPoint = selectedShipment?.orderStatus == 9;
  //   atPickUpPoint = selectedShipment?.orderStatus == 3;
  // }

  setLoadingState(bool state) {
    setState(() {
      isLoading = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    final subTitleStyle = context.textTheme.bodySmall!.copyWith(
      color: context.colorScheme.secondary,
      fontSize: 12.0,
    );
    final titleStyle = context.textTheme.bodySmall!.copyWith(fontSize: 14);
    const imageRadius = 15.0;

    return const Placeholder();
    // Scaffold(
    //   body: Stack(
    //     children: [
    //       Positioned.fill(
    //         child: ValueListenableBuilder(
    //             valueListenable: nearbyShipmentsNotifier,
    //             builder: (context, nearbyShipments, child) {
    //               return FlutterMap(
    //                 mapController: _mapController,
    //                 options: MapOptions(
    //                   initialCenter: LatLng(
    //                     widget.args.orderLat ??
    //                         nearbyShipments.firstOrNull?.pickUp?.lat ??
    //                         33.3152,
    //                     widget.args.orderLang ??
    //                         nearbyShipments.firstOrNull?.pickUp?.long ??
    //                         44.3661,
    //                   ),
    //                   initialZoom: 15,
    //                 ),
    //                 children: [
    //                   TileLayer(
    //                     urlTemplate:
    //                         "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    //                     subdomains: const ['a', 'b', 'c'],
    //                     userAgentPackageName: 'com.example.app',
    //                   ),
    //                   MarkerLayer(
    //                     key: ValueKey(nearbyShipments.length),
    //                     markers: widget.args.isOrderDetails
    //                         ? [
    //                             Marker(
    //                               width: 40,
    //                               height: 40,
    //                               point: LatLng(widget.args.orderLat ?? 33.3152,
    //                                   widget.args.orderLang ?? 44.3661),
    //                               child: Tooltip(
    //                                 message:
    //                                     "📦 ${selectedShipment?.merchantName ?? 'Unknown'}",
    //                                 child: SvgPicture.asset(
    //                                   'assets/svg/location-svgrepo-com.svg',
    //                                   color: context.colorScheme.primary,
    //                                   width: 40,
    //                                   height: 40,
    //                                 ),
    //                               ),
    //                             ),
    //                           ]
    //                         : nearbyShipments.map((shipment) {
    //                             return Marker(
    //                               width: 40,
    //                               height: 40,
    //                               point: selectedShipment!.isShipment!
    //                                   ? LatLng(
    //                                       shipment.pickUp?.lat ?? 0.0,
    //                                       shipment.pickUp?.long ?? 0.0,
    //                                     )
    //                                   : LatLng(
    //                                       shipment.deliveryLocation?.lat ?? 0.0,
    //                                       shipment.deliveryLocation?.long ??
    //                                           0.0,
    //                                     ),
    //                               child: GestureDetector(
    //                                 onTap: () {
    //                                   setState(() {
    //                                     // selectedShipment = shipment;
    //                                   });
    //                                 },
    //                                 child: Tooltip(
    //                                   message:
    //                                       "📦 ${shipment.merchantName ?? 'Unknown'}",
    //                                   child: SvgPicture.asset(
    //                                     'assets/svg/Elixire.svg',
    //                                     color: Colors.yellow,
    //                                     width: 40,
    //                                     height: 40,
    //                                   ),
    //                                 ),
    //                               ),
    //                             );
    //                           }).toList(),
    //                   ),
    //                 ],
    //               );
    //             }),
    //       ),

    //       /// HEADER CARD

    //       if (widget.args.isOrderDetails == false)
    //         Align(
    //           alignment: Alignment.topCenter,
    //           child: Container(
    //             width: double.infinity,
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.circular(20),
    //             ),
    //             child: SafeArea(
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   if (selectedShipment != null)
    //                     Stack(
    //                       children: [
    //                         if (showAppBar)
    //                           Container(
    //                             height: 70,
    //                             width: double.infinity,
    //                             color: context.colorScheme.primary
    //                                 .withOpacity(0.12),
    //                           ),
    //                         Column(
    //                           children: [
    //                             if (showAppBar)
    //                               Container(
    //                                 padding: const EdgeInsets.symmetric(
    //                                     horizontal: 16, vertical: 13),
    //                                 child: Row(
    //                                   children: [
    //                                     const SizedBox(width: 8),
    //                                     Text(
    //                                       selectedShipment?.isShipment ?? true
    //                                           ? 'هل انت متأكد من إستلام المنتجات ادناه؟'
    //                                           : 'تفاصيل الطلبية',
    //                                       style: context.textTheme.bodyMedium!
    //                                           .copyWith(
    //                                         fontWeight: FontWeight.bold,
    //                                         color: context.colorScheme.primary,
    //                                       ),
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                             Container(
    //                               width: double.infinity,
    //                               decoration: BoxDecoration(
    //                                 color: context.colorScheme.surface,
    //                                 borderRadius: BorderRadius.circular(20),
    //                                 border: Border.all(
    //                                     color: context.colorScheme.outline),
    //                               ),
    //                               padding: const EdgeInsets.symmetric(
    //                                   horizontal: 16),
    //                               child: isRefunded
    //                                   ? _buildIsRefunded(context)
    //                                   : (atPickUpPoint)
    //                                       ? _buildAtPickUpPoint()
    //                                       //TODO : update order state to user
    //                                       : (atDeliveryPoint)
    //                                           ? _buildAtDeliveryPoint(context)
    //                                           : Column(
    //                                               children: [
    //                                                 CustomAppBar(
    //                                                   padding:
    //                                                       const EdgeInsets.only(
    //                                                           top: 8,
    //                                                           bottom: 10),
    //                                                   title:
    //                                                       '${selectedShipment!.governorate}, ${selectedShipment!.zone}',
    //                                                   titleStyle: titleStyle,
    //                                                   showBackButton: false,
    //                                                   subtitle:
    //                                                       '${selectedShipment!.merchantName}',
    //                                                   subTitleStyle:
    //                                                       subTitleStyle,
    //                                                   buttonWidget:
    //                                                       const CircleAvatar(
    //                                                     backgroundImage: AssetImage(
    //                                                         "assets/images/default_avatar.jpg"),
    //                                                     radius: imageRadius,
    //                                                   ),
    //                                                 ),
    //                                                 if (!atPickUpPoint)
    //                                                   _buildNotAtPickUpPoint(
    //                                                       context,
    //                                                       titleStyle,
    //                                                       subTitleStyle,
    //                                                       imageRadius),
    //                                                 const SizedBox(height: 12),
    //                                                 (isAccepted)
    //                                                     ? _buildItsNotShipment(
    //                                                         context)
    //                                                     : _buildIsShipment(
    //                                                         context),
    //                                                 const SizedBox(height: 12),
    //                                               ],
    //                                             ),
    //                             ),
    //                           ],
    //                         ),
    //                       ],
    //                     )
    //                   else
    //                     const Column(
    //                       children: [
    //                         Text('ليس لديك أي رحلات حالياً',
    //                             style: TextStyle(fontWeight: FontWeight.bold)),
    //                         SizedBox(height: 4),
    //                         Text('اضغط على لوكيشن المتاجر لمعرفة التفاصيل',
    //                             style: TextStyle(color: Colors.grey)),
    //                       ],
    //                     ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //     ],
    //   ),
    // );
  }

  /// This method returns a [Column] widget containing a text form field
  /// The button is styled to indicate an error and shows a loading state
//   Column _buildIsRefunded(BuildContext context) {
//     return Column(
//       children: [
//         const SizedBox(height: 20),
//         const CustomTextFormField(
//           label: 'سبب الإلغاء',
//         ),
//         const SizedBox(height: 20),
//         FillButton(
//           label: 'الغاء الطلب',
//           onPressed: () {}, //TODO : update order state to user
//           isLoading: isLoading,
//           color: context.colorScheme.error,
//         ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }

//   Column _buildAtPickUpPoint() {
//     return Column(
//       children: [
//         const SizedBox(height: 20),
//         UploadOrderImageSection(
//           onImagesChanged: (List<String> paths) {
//             attachments = [...paths];
//           },
//         ),
//         const SizedBox(height: 20),
//         FillButton(
//           label: 'قبول الطلب',
//           isLoading: isLoading,
//           onPressed: () async {
//             // setLoadingState(true);
//             // // var result = await ref
//             // //     .read(shipmentsNotifierProvider.notifier)
//             // //     .receivedShipment(
//             // //         shipmentId: selectedShipment?.shipmentId ?? '',
//             // //         attachments: attachments);
//             // var result = await ref
//             //     .read(ordersNotifierProvider.notifier)
//             //     .receivedOrder(
//             //         orderId: selectedShipment?.orderId ?? '',
//             //         shipmentId: selectedShipment?.shipmentId ?? '',
//             //         attachments: attachments);
//             // setLoadingState(false);

//             // if (result.$1 != null) {
//             //   GlobalToast.show(
//             //     context: context,
//             //     message: "تم قبول الطلبية ",
//             //     backgroundColor: context.colorScheme.primary,
//             //     textColor: Colors.white,
//             //   );
//             //   // setState(() {
//             //   //   isAccepted = true;
//             //   // });
//             //   if (selectedShipment?.priority == 2) {
//             //     setState(() {
//             //       isAccepted = true;
//             //     });
//             //   } else {
//             //     // ignore: use_build_context_synchronously
//             //   }
//             // } else {
//             //   GlobalToast.show(
//             //     context: context,
//             //     message: result.$2 ?? 'حدث خطأ في قبول الطلبية ',
//             //     backgroundColor: context.colorScheme.error,
//             //     textColor: Colors.white,
//             //   );
//             // }
//           },
//           icon: SvgPicture.asset(
//             'assets/svg/tick-outline-svgrepo-com.svg',
//             color: Colors.white,
//           ),
//           reverse: true,
//         ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }

//   Column _buildNotAtPickUpPoint(BuildContext context, TextStyle titleStyle,
//       TextStyle subTitleStyle, double imageRadius) {
//     return Column(
//       children: [
//         Align(
//           alignment: Alignment.centerRight,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: context.colorScheme.primary.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: SvgPicture.asset(
//                     'assets/svg/down-arrow-svgrepo-com.svg',
//                     height: 17,
//                     width: 17,
//                   ),
//                 ),
//                 const Gap(8),
//                 Container(
//                   width: 100,
//                   height: 26,
//                   decoration: BoxDecoration(
//                     color: context.colorScheme.primary.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Center(
//                     child: Text(
//                       selectedShipment!.isPickup! ? 'استحصال' : 'توصيل',
//                     ),
//                   ),
//                 ),
//                 const Gap(8),
//                 Container(
//                   width: 100,
//                   height: 26,
//                   decoration: BoxDecoration(
//                     color: (selectedShipment?.priority ?? 0) == 2
//                         ? Colors.amberAccent.withOpacity(0.5)
//                         : context.colorScheme.secondary.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Center(
//                     child: Text(
//                       (selectedShipment?.priority ?? 0) == 2
//                           ? 'vip'
//                           : 'standerd',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         CustomAppBar(
//           padding: const EdgeInsets.only(top: 4, bottom: 8),
//           title: "المنصور، الداوودي",
//           titleStyle: titleStyle,
//           showBackButton: false,
//           subtitle: "متجر دلي",
//           subTitleStyle: subTitleStyle,
//           buttonWidget: CircleAvatar(
//             backgroundImage:
//                 const AssetImage("assets/images/default_avatar.jpg"),
//             radius: imageRadius,
//           ),
//         ),
//       ],
//     );
//   }

//   FillButton _buildIsShipment(BuildContext context) {
//     return FillButton(
//       isLoading: isLoading,
//       label: 'قبول الطلب',
//       onPressed: selectedShipment != null
//           ? () async {
//               setLoadingState(true);
//               var result = await ref
//                   .read(shipmentsNotifierProvider.notifier)
//                   .assign(shipmentId: selectedShipment!.shipmentId ?? '');
//               setLoadingState(false);
//               if (result.$1 != null) {
//                 GlobalToast.show(
//                   context: context,
//                   message: "تم قبول الطلبية ",
//                   backgroundColor: context.colorScheme.primary,
//                   textColor: Colors.white,
//                 );
//                 setState(() {
//                   isAccepted = true;
//                 });
//               } else {
//                 GlobalToast.show(
//                   context: context,
//                   message: result.$2 ?? 'حدث خطأ في قبول الطلبية ',
//                   backgroundColor: context.colorScheme.error,
//                   textColor: Colors.white,
//                 );
//               }
//             }
//           : () {},
//       icon: SvgPicture.asset(
//         'assets/svg/tick-outline-svgrepo-com.svg',
//         color: Colors.white,
//       ),
//       reverse: true,
//     );
//   }

//   Row _buildItsNotShipment(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         SizedBox(
//           width: 165,
//           child: FillButton(
//             isLoading: isLoading,
//             label: selectedShipment!.isPickup! ? 'عند التاجر' : 'عند الزبون',
//             onPressed: () async {
//               setLoadingState(true);
//               var result;
//               if (selectedShipment!.isPickup!) {
//                 result = await ref
//                     .read(shipmentsNotifierProvider.notifier)
//                     .atPickupPoint(
//                       shipmentId: selectedShipment?.shipmentId ?? '',
//                     );
//               } else {
//                 result = await ref
//                     .read(ordersNotifierProvider.notifier)
//                     .atDeliveryPoint(
//                       orderId: selectedShipment?.orderId ?? '',
//                       shipmentId: selectedShipment?.shipmentId ?? '',
//                     );
//               }
//               setLoadingState(false);
//               if (result?.$1 == null) {
//                 GlobalToast.show(
//                     context: context,
//                     message: result?.$2 ?? '',
//                     backgroundColor: context.colorScheme.error);
//               } else {
//                 GlobalToast.show(
//                     context: context,
//                     message: 'تم تغيير حالة الطلب بنجاح',
//                     backgroundColor: context.colorScheme.primary);
//                 setState(() {
//                   selectedShipment!.isPickup!
//                       ? atPickUpPoint = true
//                       : atDeliveryPoint = true;
//                 });
//               }
//             },
//           ),
//         ),
//         //TODO :refound from the marchent
//         // SizedBox(
//         //   width: 155,
//         //   child: OutlinedCustomButton(
//         //     label: 'مؤجل',
//         //     textColor: const Color(0xffBDBF40),
//         //     borderColor: const Color(0xffBDBF40),
//         //     onPressed: () async {
//         //       setLoadingState(true);
//         //       var result = await ref
//         //           .read(ordersNotifierProvider.notifier)
//         //           .changeOrderSendingState(
//         //               orderId: selectedShipment?.orderId ?? '',
//         //               shipmentId: selectedShipment?.shipmentId ?? '',
//         //               status: 12);
//         //       setLoadingState(false);
//         //       if (result?.$1 == null) {
//         //         GlobalToast.show(
//         //             co`ntext: context,
//         //             message: result?.$2 ?? '',
//         //             backgroundColor: context.colorScheme.error);
//         //       } else {
//         //         GlobalToast.show(
//         //             context: context,
//         //             message: 'تم تاجيل الطلب  ',
//         //             backgroundColor: context.colorScheme.primary);

//         //       }
//         //     },
//         //   ),
//         // ),
//       ],
//     );
//   }

//   Column _buildAtDeliveryPoint(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 20),
//         if (selectedShipment?.isOTP ?? false)
//           Column(
//             children: [
//               Text(
//                 'رمز التحقق',
//                 style: context.textTheme.bodyMedium!.copyWith(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 24.w),
//                 child: Form(
//                   key: _formKey,
//                   child: PinCodeTextField(
//                     validator: (value) {
//                       if (value!.length != 4) {
//                         return 'Invalid OTP';
//                       }

//                       return null;
//                     },
//                     controller: _codeController,
//                     appContext: context,
//                     length: 4,
//                     autoFocus: true,
//                     keyboardType: TextInputType.number,
//                     animationType: AnimationType.fade,
//                     enableActiveFill: true,
//                     cursorColor: Colors.black,
//                     pinTheme: PinTheme(
//                       shape: PinCodeFieldShape.box,
//                       borderRadius: BorderRadius.circular(9),
//                       fieldHeight: 45.w,
//                       fieldWidth: 45.w,
//                       inactiveFillColor:
//                           const Color(0xFF86BEED).withOpacity(0.3),
//                       activeFillColor: const Color(0xFF86BEED).withOpacity(0.5),
//                       selectedFillColor: const Color(0xFF86BEED),
//                       inactiveColor: Colors.transparent,
//                       activeColor: Colors.transparent,
//                       selectedColor: Colors.transparent,
//                     ),
//                     animationDuration: const Duration(milliseconds: 200),
//                     backgroundColor: Colors.transparent,
//                     onChanged: (code) {},
//                     beforeTextPaste: (text) => true,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         const SizedBox(height: 20),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             SizedBox(
//               width: 165,
//               child: FillButton(
//                 isLoading: isLoading,
//                 label: (selectedShipment?.isOTP ?? false)
//                     ? 'ارسال رمز التحقق'
//                     : 'تم تسليم الطلب',
//                 onPressed: () async {
//                   (Order?, String?)? result;
//                   setLoadingState(true);
//                   if (!(selectedShipment?.isOTP ?? false)) {
//                     result = await ref
//                         .read(ordersNotifierProvider.notifier)
//                         .delivered(
//                           orderId: selectedShipment?.orderId ?? '',
//                           shipmentId: selectedShipment?.shipmentId ?? '',
//                         );
//                   } else {
//                     if (_formKey.currentState!.validate()) {
//                       result = await ref
//                           .read(ordersNotifierProvider.notifier)
//                           .verifyOtp(
//                             orderId: selectedShipment?.orderId ?? '',
//                             shipmentId: selectedShipment?.shipmentId ?? '',
//                             otp: _codeController.text,
//                           );
//                       isCompleted = true;
//                     }
//                   }

//                   setLoadingState(false);
//                   if (result?.$1 == null) {
//                     GlobalToast.show(
//                         context: context,
//                         message: result?.$2 ?? '',
//                         backgroundColor: context.colorScheme.error);
//                     _codeController.clear();
//                     setState(() {
//                       isCompleted = false;
//                     });
//                   } else {
//                     GlobalToast.show(
//                         context: context,
//                         message: selectedShipment!.isOTP!
//                             ? 'تم ارسال رمز التحقق'
//                             : 'تم تسليم الطلب ',
//                         backgroundColor: context.colorScheme.primary);

//                     // if (isCompleted) {
//                     //   if (nearbyShipmentsNotifier.value.isEmpty) {
//                     //     if (context.mounted) {
//                     //       // showMapNotifier.value = false;
//                     //       context.pushReplacement(AppRoutes.home);
//                     //     }
//                     //   } else {
//                     //     invokeNearbyShipment();
//                     //   }
//                     // }
//                   }
//                 },
//               ),
//             ),
//             SizedBox(
//               width: 155,
//               child: OutlinedCustomButton(
//                 label: 'راجع',
//                 textColor: context.colorScheme.error,
//                 borderColor: context.colorScheme.error,
//                 onPressed: () async {
//                   setLoadingState(true);
//                   var result = await ref
//                       .read(ordersNotifierProvider.notifier)
//                       .changeOrderSendingState(
//                           orderId: selectedShipment?.orderId ?? '',
//                           shipmentId: selectedShipment?.shipmentId ?? '',
//                           status: 14);
//                   setLoadingState(false);

//                   if (result?.$1 == null) {
//                     GlobalToast.show(
//                         context: context,
//                         message: result?.$2 ?? '',
//                         backgroundColor: context.colorScheme.error);
//                   } else {
//                     GlobalToast.show(
//                         context: context,
//                         message: 'تم ارجاع الطلب ',
//                         backgroundColor: context.colorScheme.primary);
//                     setState(() {
//                       isRefunded = true;
//                       // selectedShipment = null;
//                     });
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 10),
//       ],
//     );
//   }
}
