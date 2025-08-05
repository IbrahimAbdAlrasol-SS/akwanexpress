import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Tosell/Features/support/providers/chat_provider.dart';

class UnreadMessagesBadge extends ConsumerWidget {
  final Widget child;
  final bool showBadge;

  const UnreadMessagesBadge({
    Key? key,
    required this.child,
    this.showBadge = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showBadge) return child;

    final unreadCount = ref.watch(chatMessagesProvider.select(
      (messages) => messages.where((msg) {
        final notifier = ref.read(chatMessagesProvider.notifier);
        return !msg.isRead && !notifier.isMyMessage(msg);
      }).length,
    ));

    return Stack(
      children: [
        child,
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              constraints: BoxConstraints(
                minWidth: 20.w,
                minHeight: 20.h,
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class AnimatedUnreadBadge extends ConsumerStatefulWidget {
  final Widget child;
  final bool showBadge;

  const AnimatedUnreadBadge({
    Key? key,
    required this.child,
    this.showBadge = true,
  }) : super(key: key);

  @override
  ConsumerState<AnimatedUnreadBadge> createState() =>
      _AnimatedUnreadBadgeState();
}

class _AnimatedUnreadBadgeState extends ConsumerState<AnimatedUnreadBadge>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showBadge) return widget.child;

    final unreadCount = ref.watch(chatMessagesProvider.select(
      (messages) => messages.where((msg) {
        final notifier = ref.read(chatMessagesProvider.notifier);
        return !msg.isRead && !notifier.isMyMessage(msg);
      }).length,
    ));

    // تشغيل الأنيميشن عند وجود رسائل غير مقروءة
    if (unreadCount > 0) {
      if (!_scaleController.isAnimating) {
        _scaleController.forward();
      }
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _scaleController.reverse();
    }

    return Stack(
      children: [
        widget.child,
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white, width: 2.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8.r,
                            spreadRadius: 2.r,
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(
                        minWidth: 20.w,
                        minHeight: 20.h,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
