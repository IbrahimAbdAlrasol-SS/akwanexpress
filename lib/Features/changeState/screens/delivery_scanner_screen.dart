import 'package:Tosell/Features/order/screens/order_details_screen.dart';
import 'package:Tosell/Features/shipments/models/Shipment.dart';
import 'package:Tosell/Features/shipments/providers/orders_provider.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeliveryScannerArgs {
  final Shipment shipment;

  DeliveryScannerArgs({
    required this.shipment,
  });
}

class DeliveryScannerScreen extends ConsumerStatefulWidget {
  final DeliveryScannerArgs args;
  const DeliveryScannerScreen({super.key, required this.args});

  @override
  ConsumerState<DeliveryScannerScreen> createState() =>
      _DeliveryScannerScreenState();
}

class _DeliveryScannerScreenState extends ConsumerState<DeliveryScannerScreen> {
  MobileScannerController? scannerController;
  TextEditingController codeController = TextEditingController();
  var receivedOrders = 0;
  bool isLoading = false;

  bool isFlashOn = false;
  bool isQRCode = true;
  bool hasScanned = false;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void toggleFlash() async {
    try {
      await scannerController?.toggleTorch();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      debugPrint("Flash toggle failed: $e");
    }
  }

  void switchMode(bool toQR) {
    if (isQRCode == toQR) return;

    setState(() {
      isQRCode = toQR;
      hasScanned = false;
    });
  }

  @override
  void dispose() {
    scannerController?.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (scannerController != null)
            MobileScanner(
                key: ValueKey(scannerController),
                controller: scannerController,
                onDetect: (capture) async {
                  final barcode = capture.barcodes.first;
                  final value = barcode.rawValue;

                  if (value == null) return;

                  if (isQRCode && barcode.format != BarcodeFormat.qrCode)
                    return;
                  if (!isQRCode &&
                      !(barcode.format == BarcodeFormat.code128 ||
                          barcode.format == BarcodeFormat.code39 ||
                          barcode.format == BarcodeFormat.code93 ||
                          barcode.format == BarcodeFormat.code39 ||
                          barcode.format == BarcodeFormat.ean13)) return;

                  if (isLoading) return;
                  isLoading = true;

                  try {
                    var code = value;
                    if (code == null || code.isEmpty) {
                      print('❌ Scanner was cancelled or returned null');

                      return;
                    }

                    print('📦 Scanned code: $code');

                    // Step 3: Fetch order by scanned code
                    final orderResult = await ref
                        .read(ordersNotifierProvider.notifier)
                        .getOrderByCode(
                          shipmentId: widget.args.shipment.id!,
                          code: code,
                        );

                    // Step 4: Handle failed lookup
                    if (orderResult.$1 == null) {
                      GlobalToast.show(
                        context: context,
                        message: orderResult.$2 ?? 'لم يتم العثور على الطلب',
                        backgroundColor: context.colorScheme.error,
                      );
                      return;
                    }

                    if (!context.mounted) {
                      print('⚠️ Widget no longer mounted — skip navigation');
                      return;
                    }

                    if (!context.mounted) return;

                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) {
                        context.push(
                          AppRoutes.orderDetails,
                          extra: OrderDetailsArgs(
                            id: orderResult.$1!.id!,
                            shipment: widget.args.shipment,
                            isPickup: false,
                          ),
                        );
                      },
                    );
                  } finally {
                    isLoading = false;
                  }
                }),

          // UI Overlay
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    CustomAppBar(
                      title: isQRCode ? 'مسح رمز QR' : 'مسح الباركود',
                      showBackButton: true,
                      // onBackButtonPressed: () => context.go(AppRoutes.home),
                      titleColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => switchMode(false),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !isQRCode
                                        ? const Color(0xFF00D084)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.qr_code_scanner,
                                          color: !isQRCode
                                              ? Colors.white
                                              : const Color(0xff698596)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'باركود',
                                        style: TextStyle(
                                          color: !isQRCode
                                              ? Colors.white
                                              : const Color(0xff698596),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => switchMode(true),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isQRCode
                                        ? const Color(0xFF00D084)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.qr_code_2,
                                          color: isQRCode
                                              ? Colors.white
                                              : const Color(0xff698596)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'QR',
                                        style: TextStyle(
                                          color: isQRCode
                                              ? Colors.white
                                              : const Color(0xff698596),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: SizedBox(
                        height: 220.h,
                        child: CustomPaint(
                          painter: CornerBorderPainter(),
                          child: const SizedBox(width: 250, height: 250),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: ElevatedButton(
                        onPressed: toggleFlash,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("إضاءة الفلاش"),
                            SizedBox(width: 8),
                            Icon(Icons.flash_on),
                          ],
                        ),
                      ),
                    ),
                    CustomTextFormField(
                      hint: 'ادخل الرمز يدويا',
                      controller: codeController,
                    ),
                    const SizedBox(height: 10),
                    FillButton(
                      label: 'تأكيد',
                      onPressed: () async {
                        final value = codeController.text.trim();
                        if (value.isEmpty) {
                          GlobalToast.show(
                            context: context,
                            message: 'يرجى إدخال الرمز',
                            backgroundColor: context.colorScheme.error,
                          );
                        }

                        var code = value;

                        print('📦 Scanned code: $code');

                        final orderResult = await ref
                            .read(ordersNotifierProvider.notifier)
                            .getOrderByCode(
                              shipmentId: widget.args.shipment.id!,
                              code: code,
                            );

                        if (orderResult.$1 == null) {
                          GlobalToast.show(
                            context: context,
                            message:
                                orderResult.$2 ?? 'لم يتم العثور على الطلب',
                            backgroundColor: context.colorScheme.error,
                          );
                          return;
                        }

                        if (!context.mounted) {
                          print(
                              '⚠️ Widget no longer mounted — skip navigation');
                          return;
                        }

                        if (!context.mounted) return;

                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) {
                            context.push(
                              AppRoutes.orderDetails,
                              extra: OrderDetailsArgs(
                                id: orderResult.$1!.id!,
                                shipment: widget.args.shipment,
                                isPickup: false,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CornerBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roundedPaint = Paint()
      ..color = const Color(0xFF00FFAA)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final flatPaint = Paint()
      ..color = const Color(0xFF00FFAA)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    const double lineLength = 80;

    // Top-left
    canvas.drawLine(const Offset(0, 0), Offset(lineLength, 0), roundedPaint);
    canvas.drawLine(const Offset(0, 0), Offset(0, lineLength), roundedPaint);

    // Top-right
    canvas.drawLine(Offset(size.width - lineLength, 0), Offset(size.width, 0),
        roundedPaint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, lineLength), roundedPaint);

    // Bottom-left
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - lineLength), flatPaint);
    canvas.drawLine(
        Offset(0, size.height), Offset(lineLength, size.height), flatPaint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - lineLength, size.height), flatPaint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - lineLength), flatPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
