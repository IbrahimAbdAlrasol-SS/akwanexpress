import 'package:Tosell/Features/support/providers/chat_provider.dart';
import 'package:Tosell/Features/support/screens/chat/Input_bar.dart';
import 'package:Tosell/Features/support/screens/chat/agent_info.dart';
import 'package:Tosell/Features/support/screens/chat/chat_header.dart';
import 'package:Tosell/Features/support/screens/chat/chat_message_bubble.dart';
import 'package:Tosell/core/helpers/chat_hub_connection.dart';
import 'package:Tosell/core/helpers/sharedPreferencesHelper.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_core/signalr_core.dart';

class SupportChatScreen extends ConsumerStatefulWidget {
  final String ticketId;
  const SupportChatScreen({super.key, required this.ticketId});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  String? currentUserId;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      await _loadCurrentUser();

      final notifier = ref.read(chatMessagesProvider.notifier);
      await notifier.setCurrentTicket(widget.ticketId);

      await initialConnection();
      await Future.delayed(const Duration(seconds: 2));
      final messages = ref.read(chatMessagesProvider);
      if (messages.isEmpty) {
        print('⚠️ No messages loaded, retrying...');
        await requestChatHistory(widget.ticketId);
        await Future.delayed(const Duration(seconds: 1));
      }

      // إضافة مستمع لحالة الاتصال
      _setupConnectionMonitoring();
    } catch (e) {
      print('❌ Error initializing chat: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setupConnectionMonitoring() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (chatHubConnection?.state != HubConnectionState.connected) {
        print('🔄 Connection lost, attempting to reconnect...');
        initialConnection().catchError((e) {
          print('❌ Reconnection failed: $e');
        });
      } else {
        print('🔄 Requesting chat history update...');
        requestChatHistory(widget.ticketId).catchError((e) {
          print('❌ Failed to request chat history update: $e');
        });
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    final user = await SharedPreferencesHelper.getUser();
    setState(() {
      currentUserId = user?.id;
    });
  }

  Future<void> initialConnection() async {
    if (_isDisposed) {
      print('🚫 Cannot initialize connection - widget disposed');
      return;
    }

    try {
      print('🔄 Starting chat initialization for ticket: ${widget.ticketId}');

      // الاتصال بـ SignalR
      if (!_isDisposed) {
        await initSignalRChatConnection(ref);
        print('✅ SignalR connection established');
      }

      // انتظار قصير للتأكد من استقرار الاتصال
      if (!_isDisposed) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // الانضمام إلى مجموعة الدردشة
      if (!_isDisposed) {
        await joinChatGroup(widget.ticketId);
        print('✅ Joined chat group for ticket: ${widget.ticketId}');
      }

      // انتظار قصير قبل طلب التاريخ
      if (!_isDisposed) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      if (!_isDisposed) {
        await requestChatHistory(widget.ticketId);
        print('✅ Requested chat history for ticket: ${widget.ticketId}');
      }

      if (!_isDisposed) {
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // تحديد الرسائل كمقروءة
      if (!_isDisposed) {
        await markMessagesAsRead(widget.ticketId);
        print('✅ Marked messages as read for ticket: ${widget.ticketId}');
      }
    } catch (e, s) {
      print('❌ Error in initial connection: $e');
      print('📍 Stack trace: $s');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;

    // مغادرة مجموعة الدردشة قبل إغلاق الشاشة
    leaveChatGroup(widget.ticketId);
    chatHubConnection?.stop();
    _scrollController.dispose();

    // مسح التذكرة الحالية فقط (بدون حذف الرسائل)
    try {
      final notifier = ref.read(chatMessagesProvider.notifier);
      notifier.setCurrentTicket(''); // مسح التذكرة الحالية
    } catch (e) {
      print('🚫 Cannot clear current ticket - ref disposed: $e');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final notifier = ref.read(chatMessagesProvider.notifier);

    // التمرير إلى الأسفل عند إضافة رسائل جديدة
    ref.listen(chatMessagesProvider, (previous, next) {
      if (next.length > (previous?.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.colorScheme.primary.withOpacity(0.05),
        body: Column(
          children: [
            const ChatHeader(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'جاري تحميل المحادثة...',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: context.colorScheme.secondary
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد رسائل بعد',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: context.colorScheme.secondary
                                      .withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ابدأ محادثة جديدة مع فريق الدعم',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.secondary
                                      .withOpacity(0.5),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: messages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) return const AgentInfo();
                            final msg = messages[index - 1];
                            final isMe = msg.senderId == currentUserId;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ChatMessageBubble(
                                message: msg.content ?? 'لا توجد رسالة',
                                time: _formatTime(msg.sentAt),
                                imageUrl: (msg.attachmentsUrl != null &&
                                        msg.attachmentsUrl!.isNotEmpty)
                                    ? msg.attachmentsUrl!.first
                                    : '',
                                isMe: isMe,
                                isDelivered: msg.isDelivered ?? false,
                                isRead: msg.isRead ?? false,
                              ),
                            );
                          },
                        ),
            ),
            if (!_isLoading)
              InputBar(
                  ticketId: widget.ticketId,
                  onSend: (ticketId, message) =>
                      notifier.addMessage(ticketId, message, ref)),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic sentAt) {
    if (sentAt == null) return 'غير معروف';

    try {
      DateTime dateTime;
      if (sentAt is String) {
        if (sentAt.isEmpty) return 'غير معروف';
        dateTime = DateTime.parse(sentAt);
      } else if (sentAt is DateTime) {
        dateTime = sentAt;
      } else {
        return 'غير معروف';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} دقيقة';
      } else {
        return 'الآن';
      }
    } catch (e) {
      print('Error formatting time: $e');
      return 'غير معروف';
    }
  }
}
