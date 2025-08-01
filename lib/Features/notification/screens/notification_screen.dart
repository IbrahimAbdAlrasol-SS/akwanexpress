import 'package:Tosell/Features/notification/models/notifications.dart';
import 'package:Tosell/Features/notification/services/notifications_service.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/helpers/timeAgoArabic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/helpers/date_grouping_helper.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Notifications> _allNotifications = [];
  Map<String, List<Notifications>> _groupedNotifications = {};
  List<String> _groupOrder = [];
  bool _isLoadingAllNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadAllNotifications();
  }

  Future<void> _loadAllNotifications() async {
    setState(() {
      _isLoadingAllNotifications = true;
    });

    try {
      final notificationsService = NotificationsService();
      List<Notifications> allNotifications = [];
      int currentPage = 1;
      bool hasMorePages = true;

      while (hasMorePages) {
        final response = await notificationsService.getAll(page: currentPage);
        final notifications = response.getList;

        if (notifications.isNotEmpty) {
          allNotifications.addAll(notifications);
          currentPage++;

          // Check if we have reached the last page
          // Assuming if we get less than expected items, it's the last page
          if (notifications.length < 10) {
            // Assuming 10 items per page
            hasMorePages = false;
          }
        } else {
          hasMorePages = false;
        }
      }

      setState(() {
        _allNotifications = allNotifications;
        _updateGroupedNotifications(allNotifications);
        _isLoadingAllNotifications = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAllNotifications = false;
      });
      print('Error loading all notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomAppBar(
              title: "الإشعارات",
              showBackButton: false,
            ),
            Expanded(
              child: _isLoadingAllNotifications
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _groupedNotifications.isEmpty
                      ? buildNoNotificationsFound(context)
                      : ListView.builder(
                          itemCount: _getTotalItemCount(),
                          itemBuilder: (context, index) {
                            return _buildItemAtIndex(context, index);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateGroupedNotifications(List<Notifications> notifications) {
    _groupedNotifications = DateGroupingHelper.groupByDate<Notifications>(
      notifications,
      (notification) =>
          DateTime.parse(notification.createdAt ?? DateTime.now().toString()),
    );
    _groupOrder = _groupedNotifications.keys.toList();
  }

  int _getTotalItemCount() {
    int count = 0;
    for (final group in _groupedNotifications.values) {
      count += group.length + 1; // +1 for the header
    }
    return count;
  }

  Widget _buildItemAtIndex(BuildContext context, int index) {
    int currentIndex = 0;

    for (int groupIndex = 0; groupIndex < _groupOrder.length; groupIndex++) {
      final groupKey = _groupOrder[groupIndex];
      final groupNotifications = _groupedNotifications[groupKey]!;

      // Check if this is the header for this group
      if (currentIndex == index) {
        return _buildDateHeader(context, groupKey);
      }
      currentIndex++;

      // Check if this is one of the notifications in this group
      for (int notificationIndex = 0;
          notificationIndex < groupNotifications.length;
          notificationIndex++) {
        if (currentIndex == index) {
          return notificationItemWidget(
              context, groupNotifications[notificationIndex]);
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildDateHeader(BuildContext context, String dateLabel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 8.w),
      child: Text(
        dateLabel,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

Widget notificationItemWidget(
    BuildContext context, Notifications notification) {
  return InkWell(
    onTap: () {
      context.push(AppRoutes.notificationDetails, extra: notification);
    },
    borderRadius: BorderRadius.circular(12.r),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary)),
                child: Icon(
                  CupertinoIcons.bell,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18.sp,
                ),
              ),
              const Gap(AppSpaces.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? "لايوجد",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeAgoArabic(
                              DateTime.parse(notification.createdAt!)),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: context.colorScheme.secondary),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      notification.description ?? "لايوجد",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Gap(AppSpaces.small),
              Icon(
                CupertinoIcons.chevron_right,
                color: Theme.of(context).colorScheme.secondary,
                size: 16.sp,
              ),
            ],
          ),
          //? just divider
          Divider(color: context.colorScheme.outline),
        ],
      ),
    ),
  );
}

Widget buildNoNotificationsFound(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'لا توجد إشعارات',
        style: context.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colorScheme.primary,
          fontSize: 24,
        ),
      ),
      Text(
        'سيتم اعلامك عند ارسال أي إشعار جديد',
        style: context.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w500,
          color: context.colorScheme.secondary,
          fontSize: 16,
        ),
      ),
    ],
  );
}
