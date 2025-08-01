import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef ScanOrdersCallback = Future<(dynamic, String?)?> Function(
  String code,
  String shipmentId,
);

typedef ReceiveOrderCallback = Future<(dynamic, String?)?> Function(
  String code,
  String shipmentId,
  bool isVip,
);

class ScannerArgs {
  final bool getValue;
  final int? totalCount;

  List<String>? scannedCodes;
  final String? shipmentId;
  final ScanOrdersCallback? scanOrders;
  final ReceiveOrderCallback? receiveOrder;

  ScannerArgs({
    this.shipmentId,
    this.getValue = false,
    this.totalCount,
    this.scannedCodes = const [],
    this.scanOrders,
    this.receiveOrder,
  });
}

class ScannerScreen extends StatefulWidget {
  final ScannerArgs args;
  const ScannerScreen({super.key, required this.args});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController? scannerController;
  TextEditingController codeController = TextEditingController();
  var receivedOrders = 0;
  bool isLoading = false;
  String? code;
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
    receivedOrders = widget.args.scannedCodes?.length ?? 0;
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

                  // if (widget.args.scannedCodes?.contains(value) ?? false) {
                  //   GlobalToast.show(
                  //     context: context,
                  //     message: 'العنصر مستحصل بالفعل',
                  //     backgroundColor: Colors.green,
                  //   );
                  //   return;
                  // }

                  if (isLoading) return;
                  isLoading = true;

                  try {
                    if (widget.args.getValue) {
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (context.mounted) context.pop(value);
                      return;
                    }

                    final scanOrders = widget.args.scanOrders;
                    final receiveOrder = widget.args.receiveOrder;

                    if (scanOrders != null) {
                      final orderResult =
                          await scanOrders(value, widget.args.shipmentId!);

                      if (orderResult?.$1 == null) {
                        GlobalToast.show(
                          context: context,
                          message: orderResult?.$2 ?? 'لم يتم العثور على الطلب',
                          backgroundColor: context.colorScheme.error,
                        );
                        await Future.delayed(
                            const Duration(seconds: 1)); // optional pause
                        return;
                      }

                      final receiveResult = await receiveOrder?.call(
                        orderResult!.$1!.code!,
                        widget.args.shipmentId!,
                        false,
                      );

                      if (receiveResult != null && receiveResult.$1 != null) {
                        GlobalToast.show(
                          context: context,
                          message: 'تم استلام الطلب بنجاح',
                          backgroundColor: Colors.green,
                        );
                        setState(() {
                          receivedOrders++;
                          widget.args.scannedCodes?.add(value);
                        });

                        if (receivedOrders == widget.args.totalCount!) {
                          context.pop();
                        }
                      } else {
                        GlobalToast.show(
                          context: context,
                          message: receiveResult?.$2 ?? 'فشل استلام الطلب',
                          backgroundColor: context.colorScheme.error,
                        );
                        await Future.delayed(
                            const Duration(seconds: 1)); // optional pause
                      }
                    } else {
                      context.pop(value);
                    }
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
                    if (!widget.args.getValue)
                      Text(
                        '${widget.args.totalCount} / $receivedOrders',
                        style: context.textTheme.titleLarge,
                      ),
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
                          return;
                        }

                        if (widget.args.getValue) {
                          context.pop(value);
                          return;
                        }

                        final scanOrders = widget.args.scanOrders;
                        final receiveOrder = widget.args.receiveOrder;

                        if (scanOrders != null) {
                          final orderResult =
                              await scanOrders(value, widget.args.shipmentId!);

                          if (orderResult?.$1 == null) {
                            GlobalToast.show(
                              context: context,
                              message:
                                  orderResult?.$2 ?? 'لم يتم العثور على الطلب',
                              backgroundColor: context.colorScheme.error,
                            );
                            return;
                          }

                          final receiveResult = await receiveOrder?.call(
                            orderResult!.$1!.code!,
                            widget.args.shipmentId!,
                            false,
                          );

                          if (receiveResult != null &&
                              receiveResult.$1 != null) {
                            GlobalToast.show(
                              context: context,
                              message: 'تم استلام الطلب بنجاح',
                              backgroundColor: Colors.green,
                            );
                            setState(() {
                              isLoading = false;
                              receivedOrders++;
                            });

                            if (receivedOrders == widget.args.totalCount) {
                              if (context.mounted) context.pop();
                            }
                          } else {
                            GlobalToast.show(
                              context: context,
                              message: receiveResult?.$2 ?? 'فشل استلام الطلب',
                              backgroundColor: context.colorScheme.error,
                            );
                          }
                        } else {
                          context.pop(value);
                        }
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
