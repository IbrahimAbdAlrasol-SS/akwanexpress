import 'package:Tosell/Features/shipments/widgets/shipment_cart_item.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/shipments/models/Order.dart';
import 'package:Tosell/Features/shipments/models/order_enum.dart';

class OrderCardItem extends ConsumerStatefulWidget {
  final Order order;
  final bool isPickup;
  final bool isRefound;
  final Function? onTap;

  const OrderCardItem({
    required this.order,
    this.onTap,
    required this.isPickup,
    this.isRefound = false,
    super.key,
  });

  @override
  ConsumerState<OrderCardItem> createState() => _OrderCardItemState();
}

class _OrderCardItemState extends ConsumerState<OrderCardItem> {
  @override
  Widget build(BuildContext context) {
    var order = widget.order;
    var isPickup = widget.isPickup;
    return GestureDetector(
      // onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),

              // Text content with constraints
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPickup
                          ? 'الطلب - ${order.code}'
                          : '${order.deliveryZone?.name ?? ''} - ${order.deliveryZone?.governorate?.name ?? ''}',
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (!isPickup) const SizedBox(height: 4),
                    if (!isPickup)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.customerName ?? 'لايوجد',
                              style: context.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.customerPhoneNumber ?? 'لايوجد',
                              style: context.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status widget
              buildOrderStatus(order.status!, isRefound: widget.isRefound),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildOrderStatus(int index, {bool isRefound = false}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: 100,
      height: 26,
      decoration: BoxDecoration(
        color: orderStatus[index].color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          (isRefound && index == 7)
              ? 'في قائمة راجع'
              : orderStatus[index].name!,
        ),
      ),
    ),
  );
}

Widget buildSection(
  String title,
  String iconPath,
  ThemeData theme, {
  bool isRed = false,
  bool isGray = false,
  void Function()? onTap,
  EdgeInsets? padding,
  double? textWidth,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Padding(
              padding: padding ?? const EdgeInsets.all(0),
              child: SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                color: isRed
                    ? theme.colorScheme.error
                    : isGray
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                width: textWidth,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.secondary,
                    fontFamily: "Tajawal",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
