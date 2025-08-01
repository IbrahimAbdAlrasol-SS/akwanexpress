import 'package:Tosell/Features/home/models/RejectReasons.dart';
import 'package:Tosell/Features/home/providers/reject_reson_provider.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';
import 'package:Tosell/Features/shipments/providers/orders_provider.dart';
import 'package:Tosell/Features/shipments/providers/shipments_provider.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/widgets/DatePickerTextField%20.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/core/widgets/OutlineButton.dart';
import 'package:Tosell/core/widgets/custom_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class DelayOrReturnDialog extends ConsumerStatefulWidget {
  final String shipmentId;
  final String orderId;

  const DelayOrReturnDialog({
    super.key,
    required this.orderId,
    required this.shipmentId,
  });

  @override
  ConsumerState<DelayOrReturnDialog> createState() =>
      _DelayOrReturnDialogState();
}

class _DelayOrReturnDialogState extends ConsumerState<DelayOrReturnDialog> {
  int selectedReasonIndex = 0; //? 0 for refound, 1 for delay
  DateTime? selectedDate;
  String? selectedReasonId;
  List<RejectReason> rejectReasons = [];
  var noteController = TextEditingController();
  bool isLoading = false;
  var _formKey = GlobalKey<FormState>();

  @override
  @override
  void initState() {
    super.initState();
    _loadRejectReasons(); // call async method separately
  }

  Future<void> _loadRejectReasons() async {
    final result =
        await ref.read(rejectResonNotifierProvider.notifier).getAll();
    setState(() {
      rejectReasons = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomSection(
      title: 'تأجيل / راجع',
      titleColor: context.colorScheme.error,
      icon: Icon(
        Icons.warning_amber_rounded,
        color: context.colorScheme.error,
      ),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize:
                MainAxisSize.min, // <--- Ensure content is as tight as possible
            children: [
              const SizedBox(height: 20),
              _buildTitle(label: 'تحديد السبب'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                clipBehavior: Clip.hardEdge,
                child: Row(
                  children: [
                    buildToggleOption(
                      context: context,
                      label: 'مؤجل',
                      selected: selectedReasonIndex == 1,
                      onTap: () => setState(() => selectedReasonIndex = 1),
                    ),
                    buildToggleOption(
                      context: context,
                      label: 'راجع',
                      selected: selectedReasonIndex == 0,
                      onTap: () => setState(() => selectedReasonIndex = 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // if (selectedReasonIndex == 1)
              //   _buildDelayDate(
              //     theme,
              //     context,
              //     (value) {
              //       if (selectedDate == null) {
              //         return 'يرجا اختيار موعد التسليم القادم';
              //       }
              //       return null;
              //     },
              //   ),
              if (selectedReasonIndex == 0)
                _buildReturnReason(
                  theme,
                  context,
                  (value) {
                    if (selectedReasonId == null) {
                      return 'يرجا اختيار سبب الرفض او الارجاع';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 10),
              _buildTitle(label: 'ملاحظة'),
              CustomTextFormField(
                controller: noteController,
                validator: (value) {
                  if ((value?.length ?? 0) <= 5) {
                    return 'خمس احرف كحد ادنى';
                  }
                  return null;
                },
                hint: 'الزبون الغا الطلب',
                radius: 16,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                textDirection: TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedCustomButton(
                      label: 'رجوع',
                      borderRadius: 16,
                      textColor: theme.colorScheme.onSurface,
                      borderColor: theme.colorScheme.outline,
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  ),
                  const Gap(AppSpaces.medium),
                  Expanded(
                    child: FillButton(
                      isLoading: isLoading,
                      borderRadius: 16,
                      label: 'تأكيد',
                      color: context.colorScheme.primary,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _setLoadingState(true);
                          (Order?, String?) result;

                          if (selectedReasonIndex == 0) {
                            result = await ref
                                .read(ordersNotifierProvider.notifier)
                                .delayOrReturnOrder(
                                  shipmentId: widget.shipmentId,
                                  orderId: widget.orderId,
                                  status: 17,
                                  rejectReasonId: selectedReasonId,
                                  note: noteController.text,
                                );
                          } else {
                            result = await ref
                                .read(ordersNotifierProvider.notifier)
                                .delayOrReturnOrder(
                                  shipmentId: widget.shipmentId,
                                  orderId: widget.orderId,
                                  status: 15,
                                  recycledTo: selectedDate.toString(),
                                  note: noteController.text,
                                );
                          }

                          _setLoadingState(false);
                          if (result.$1 == null) {
                            GlobalToast.show(
                              context: context,
                              backgroundColor: context.colorScheme.error,
                              message: result.$2 ?? 'unKnown error',
                            );
                          } else {
                            GlobalToast.show(
                              context: context,
                              backgroundColor: context.colorScheme.error,
                              message: 'تم تغيير الحالة',
                            );
                            ref.invalidate(
                                getShipmentByIdProvider(widget.shipmentId));
                            context.go(AppRoutes.shipments);
                          }
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

  void _setLoadingState(bool state) {
    return setState(() {
      isLoading = state;
    });
  }

  String? selectedOption;

  Column _buildDelayDate(
    ThemeData theme,
    BuildContext context,
    String? Function(String?)? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(label: 'موعد التسليم'),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: selectedOption,
          decoration: InputDecoration(
            hintText: 'يرجى اختيار موعد التسليم',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.colorScheme.outline),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: const [
            DropdownMenuItem(
              value: 'day',
              child: Text('يوم'),
            ),
            DropdownMenuItem(
              value: 'ُtowDays',
              child: Text('يومين'),
            ),
            DropdownMenuItem(
              value: 'week',
              child: Text('أسبوع'),
            ),
          ],
          validator: (value) {
            if (selectedDate == null) {
              return 'يرجى اختيار موعد التسليم القادم';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              selectedOption = value;

              // ✅ Automatically calculate delivery date
              if (value == 'day') {
                selectedDate = DateTime.now().add(const Duration(days: 1));
              } else if (value == 'week') {
                selectedDate = DateTime.now().add(const Duration(days: 7));
              } else if (value == 'ُtowDays') {
                selectedDate = DateTime.now().add(const Duration(days: 2));
              }
            });
          },
        ),
        const SizedBox(height: 8),
        // Optional read-only field showing selected date
        if (selectedDate != null)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colorScheme.outline),
              color: Colors.grey.shade100,
            ),
            child: Text(
              'تاريخ التسليم: ${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
              style: context.textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }

  Widget _buildReturnReason(
    ThemeData theme,
    BuildContext context,
    String? Function(String?)? validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(label: 'سبب الإرجاع'),
        CustomTextFormField<String>(
          validator: (_) {
            if (selectedReasonId == null || selectedReasonId!.isEmpty) {
              return 'يرجا اختيار سبب الرفض او الارجاع';
            }
            return null;
          },
          selectedValue: selectedReasonId,
          hint: 'الزبون رفض الاستلام',
          radius: 16,
          dropdownItems: rejectReasons.map((reason) {
            return DropdownMenuItem<String>(
              value: reason.id, // use the ID as value
              child: Text(reason.reason ?? 'لايوجد'), // show the name
            );
          }).toList(),
          onDropdownChanged: (value) {
            setState(() {
              selectedReasonId = value;
            });
          },
          suffixInner: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              "assets/svg/CaretDown.svg",
              width: 24,
              color: context.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Text _buildTitle({TextStyle? labelStyle, required String label}) {
    return Text(label, style: labelStyle ?? context.textTheme.titleMedium);
  }
}

Widget buildToggleOption({
  required BuildContext context,
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        // color: selected
        //     ? context.colorScheme.primary.withOpacity(0.1)
        //     : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? context.colorScheme.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: selected ? context.colorScheme.primary : Colors.grey,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
