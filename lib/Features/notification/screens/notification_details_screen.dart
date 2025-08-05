import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:Tosell/Features/notification/models/notifications.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/helpers/timeAgoArabic.dart';
import 'package:Tosell/core/utils/extensions.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final Notifications notification;

  const NotificationDetailsScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: "التفاصيل",
              showBackButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and basic info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              CupertinoIcons.bell_fill,
                              color: Theme.of(context).colorScheme.primary,
                              size: 40.sp,
                            ),
                          ),
                          Gap(AppSpaces.medium),
                          Text(
                            notification.title ?? "لا يوجد عنوان",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          Gap(AppSpaces.small),
                          Text(
                            timeAgoArabic(DateTime.parse(
                                notification.createdAt ??
                                    DateTime.now().toString())),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ],
                      ),
                    ),

                    Gap(AppSpaces.large),

                    // Details section
                    Text(
                      "تفاصيل الإشعار",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    Gap(AppSpaces.medium),

                    // Notification details cards

                    _buildDetailCard(
                      context,
                      "العنوان",
                      notification.title ?? "لا يوجد عنوان",
                      CupertinoIcons.textformat,
                    ),

                    Gap(AppSpaces.small),

                    _buildDetailCard(
                      context,
                      "الوصف",
                      notification.description ?? "لا يوجد وصف",
                      CupertinoIcons.doc_text,
                      isLongText: true,
                    ),

                    Gap(AppSpaces.small),

                    _buildDetailCard(
                      context,
                      "نوع الإشعار",
                      _getNotificationType(notification.type),
                      CupertinoIcons.tag,
                    ),

                    Gap(AppSpaces.small),

                    _buildDetailCard(
                      context,
                      "تاريخ الإنشاء",
                      _formatDate(notification.createdAt),
                      CupertinoIcons.calendar,
                    ),

                    if (notification.notifyFor != null) ...[
                      Gap(AppSpaces.small),
                      _buildDetailCard(
                        context,
                        "مخصص لـ",
                        notification.notifyFor!,
                        CupertinoIcons.person,
                      ),
                    ],

                    Gap(12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isLongText = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20.sp,
            ),
          ),
          Gap(AppSpaces.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Gap(12),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getNotificationType(int? type) {
    switch (type) {
      case 0:
        return "إشعار عام";
      case 1:
        return "إشعار طلب";
      case 2:
        return "إشعار نظام";
      case 3:
        return "إشعار تحديث";
      default:
        return "غير محدد";
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "غير محدد";

    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "تاريخ غير صحيح";
    }
  }
}
