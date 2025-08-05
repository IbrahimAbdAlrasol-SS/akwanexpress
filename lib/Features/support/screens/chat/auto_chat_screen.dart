import 'package:Tosell/Features/support/providers/chat_provider.dart';
import 'package:Tosell/Features/support/screens/chat/Input_bar.dart';
import 'package:Tosell/Features/support/screens/chat/agent_info.dart';
import 'package:Tosell/Features/support/screens/chat/chat_header.dart';
import 'package:Tosell/Features/support/screens/chat/chat_message_bubble.dart';
import 'package:Tosell/Features/support/screens/chat/chat_screen.dart';
import 'package:Tosell/core/helpers/chat_hub_connection.dart';
import 'package:Tosell/core/helpers/sharedPreferencesHelper.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AutoChatScreen extends ConsumerStatefulWidget {
  const AutoChatScreen({super.key});

  @override
  ConsumerState<AutoChatScreen> createState() => _AutoChatScreenState();
}

class _AutoChatScreenState extends ConsumerState<AutoChatScreen> {
  String? currentUserId;
  String? activeTicketId;
  bool _isLoading = true;
  String _loadingMessage = 'جاري البحث عن محادثتك...';

  @override
  void initState() {
    super.initState();
    _initializeAutoChat();
  }

  Future<void> _initializeAutoChat() async {
    try {
      setState(() {
        _loadingMessage = 'جاري تحميل بيانات المستخدم...';
      });

      // تحميل بيانات المستخدم
      final user = await SharedPreferencesHelper.getUser();
      if (user?.id == null) {
        _showError('لم يتم العثور على بيانات المستخدم');
        return;
      }

      setState(() {
        currentUserId = user!.id;
        _loadingMessage = 'جاري الاتصال بخدمة الدردشة...';
      });

      // الاتصال بـ SignalR
      await initSignalRChatConnection(ref);

      setState(() {
        _loadingMessage = 'جاري البحث عن تذكرتك النشطة...';
      });

      // البحث عن التذكرة النشطة للمستخدم
      final ticketId = await getUserActiveTicket();

      if (ticketId != null && ticketId.isNotEmpty) {
        // إذا وُجدت تذكرة نشطة، انتقل إلى شاشة الدردشة
        setState(() {
          activeTicketId = ticketId;
          _loadingMessage = 'جاري تحميل محادثتك...';
        });

        // الانتقال إلى شاشة الدردشة مع التذكرة الموجودة
        if (mounted) {
          context.pushReplacement(AppRoutes.chat, extra: ticketId);
        }
      } else {
        // إذا لم توجد تذكرة نشطة، انتقل إلى إنشاء تذكرة جديدة
        setState(() {
          _loadingMessage = 'لم يتم العثور على محادثة نشطة...';
        });

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          context.pushReplacement(AppRoutes.createTicket);
        }
      }
    } catch (e) {
      print('❌ Error in auto chat initialization: $e');
      _showError('حدث خطأ أثناء تحميل المحادثة');
    }
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('خطأ'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pushReplacement(AppRoutes.createTicket);
              },
              child: const Text('إنشاء تذكرة جديدة'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('العودة'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.colorScheme.primary.withOpacity(0.05),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // شعار التطبيق أو أيقونة الدردشة
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 40,
                  color: context.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // مؤشر التحميل
              CircularProgressIndicator(
                color: context.colorScheme.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),

              // رسالة التحميل
              Text(
                _loadingMessage,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // رسالة فرعية
              Text(
                'يرجى الانتظار...',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.secondary.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // زر الإلغاء
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: context.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
