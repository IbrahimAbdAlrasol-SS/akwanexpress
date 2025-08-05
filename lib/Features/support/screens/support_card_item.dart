import 'package:Tosell/Features/support/models/ticket.dart';
import 'package:Tosell/Features/support/screens/support_enum.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SupportCardItem extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isExpanded;
  final Ticket ticket;

  const SupportCardItem({
    super.key,
    this.onTap,
    required this.ticket,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onTap ?? () => context.push(AppRoutes.chat, extra: ticket.id),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colorScheme.outline),
            color: context.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: context.colorScheme.primary.withOpacity(0.1),
                    border: Border.all(
                      color: context.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.support_agent,
                    color: context.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Expanded Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.subject ?? 'بدون عنوان',
                        style: context.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ticket.description ?? 'بدون وصف',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.secondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 16,
                            color: context.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'رقم التذكرة: ${ticket.id?.substring(0, 8) ?? 'غير محدد'}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Status
                buildTicketState(ticket.status ?? 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildTicketState(int status) {
  String statusText;
  Color statusColor;

  switch (status) {
    case 0:
      statusText = 'مفتوح';
      statusColor = Colors.blue;
      break;
    case 1:
      statusText = 'قيد المعالجة';
      statusColor = Colors.orange;
      break;
    case 2:
      statusText = 'مغلق';
      statusColor = Colors.green;
      break;
    case 3:
      statusText = 'ملغي';
      statusColor = Colors.red;
      break;
    default:
      statusText = 'غير محدد';
      statusColor = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: statusColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: statusColor.withOpacity(0.3)),
    ),
    child: Text(
      statusText,
      style: TextStyle(
        color: statusColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
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
