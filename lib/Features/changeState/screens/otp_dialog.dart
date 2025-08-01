import 'dart:async';
import 'package:Tosell/Features/home/screens/vip/vip_order_screen.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';
import 'package:Tosell/Features/shipments/providers/orders_provider.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/OutlineButton.dart';
import 'package:Tosell/core/widgets/custom_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpDialogArgs {
  final Order order;
  final String shipmentId;
  final bool isVip;
  const OtpDialogArgs(
      {required this.order, required this.shipmentId, this.isVip = false});
}

class OtpDialog extends ConsumerStatefulWidget {
  final OtpDialogArgs args;
  const OtpDialog({super.key, required this.args});

  @override
  ConsumerState<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends ConsumerState<OtpDialog> {
  bool isLoading = false;
  bool secondLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _noteController = TextEditingController();

  int _secondsRemaining = 30;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _canResend = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: 'تأكيد التسليم',
      icon: SvgPicture.asset(
        'assets/svg/Checks.svg',
        color: context.colorScheme.primary,
      ),
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Form(
                key: _formKey,
                child: PinCodeTextField(
                  controller: _codeController,
                  appContext: context,
                  length: 4,
                  autoFocus: true,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  enableActiveFill: true,
                  cursorColor: Colors.black,
                  validator: (value) {
                    if (value == null || value.length != 4) {
                      return 'رمز غير صحيح';
                    }
                    return null;
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(9),
                    fieldHeight: 55.w,
                    fieldWidth: 55.w,
                    inactiveFillColor: context.colorScheme.surface,
                    activeFillColor:
                        context.colorScheme.primary.withOpacity(0.5),
                    selectedFillColor: const Color(0xFF86BEED),
                    inactiveColor: context.colorScheme.outline,
                    activeColor: context.colorScheme.outline,
                    selectedColor: context.colorScheme.outline,
                  ),
                  animationDuration: const Duration(milliseconds: 200),
                  backgroundColor: Colors.transparent,
                  onChanged: (_) {},
                  beforeTextPaste: (text) => true,
                ),
              ),
            ),
            const Gap(AppSpaces.small),
            CustomTextFormField(
              label: 'ملاحظات إضافية',
              controller: _noteController,
              maxLines: 3,
            ),
            const Gap(AppSpaces.small),
            _canResend
                ? GestureDetector(
                    onTap: () async {
                      setState(() => secondLoading = true);
                      final result = await ref
                          .read(ordersNotifierProvider.notifier)
                          .reSendOtp(orderId: widget.args.order.id!);
                      setState(() => secondLoading = false);

                      if (result.$1 == null) {
                        GlobalToast.show(
                          context: context,
                          message: result.$2 ?? 'حدث خطأ',
                          backgroundColor: context.colorScheme.error,
                        );
                      } else {
                        GlobalToast.show(
                          context: context,
                          message: 'تم إرسال الرمز بنجاح',
                          backgroundColor: context.colorScheme.primary,
                        );
                        _startTimer();
                      }
                    },
                    child: Text(
                      'إعادة إرسال الرمز',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    'يمكنك إعادة الإرسال خلال $_secondsRemaining ثانية',
                    style: TextStyle(color: context.colorScheme.secondary),
                  ),
            const Gap(AppSpaces.medium),
            buildInvoice(context, widget.args.order),
            Row(
              children: [
                Expanded(
                  child: FillButton(
                    isLoading: isLoading,
                    color: Colors.green,
                    borderRadius: 16,
                    label: 'تأكيد',
                    onPressed: () async {
                      setState(() => isLoading = true);
                      if (_formKey.currentState!.validate()) {
                        final result = await ref
                            .read(ordersNotifierProvider.notifier)
                            .verifyOtp(
                              orderId: widget.args.order.id!,
                              isVip: false,
                              shipmentId: widget.args.shipmentId,
                              otp: _codeController.text,
                            );
                        setState(() => isLoading = false);
                        if (result.$1 == null) {
                          GlobalToast.show(
                            context: context,
                            message: result.$2 ?? '',
                            backgroundColor: context.colorScheme.error,
                          );
                          _codeController.clear();
                        } else {
                          GlobalToast.show(
                            context: context,
                            message: 'تمت العملية بنجاح',
                            backgroundColor: context.colorScheme.primary,
                          );
                          if (context.mounted) {
                            if (widget.args.isVip) {
                              context.go(AppRoutes.vipHome);
                            } else {
                              context.go(AppRoutes.shipments);
                            }
                          }
                        }
                      }
                    },
                  ),
                ),
                const Gap(AppSpaces.small),
                Expanded(
                  child: OutlinedCustomButton(
                    textColor: context.colorScheme.onSurface,
                    borderColor: context.colorScheme.outline,
                    borderRadius: 16,
                    label: 'الرجوع',
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
