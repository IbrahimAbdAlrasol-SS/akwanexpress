import 'package:Tosell/Features/support/models/chat_message.dart';
import 'package:Tosell/Features/support/services/message_service.dart';
import 'package:Tosell/core/helpers/SharedPreferencesHelper.dart';
import 'package:Tosell/core/helpers/chat_hub_connection.dart';
import 'package:Tosell/core/services/notification_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]) {
    // تحميل الرسائل المحفوظة عند بدء التطبيق
    _loadMessagesFromLocal();
  }
  MessageService _service = MessageService();
  String? _currentUserId;
  String? _currentTicketId; // إضافة متتبع للتذكرة الحالية

  // خريطة لحفظ الرسائل لكل تذكرة منفصلة
  final Map<String, List<ChatMessage>> _ticketMessages = {};

  // حفظ الرسائل محلياً
  Future<void> _saveMessagesToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> allMessages = {};

      for (final entry in _ticketMessages.entries) {
        allMessages[entry.key] =
            entry.value.map((msg) => msg.toJson()).toList();
      }

      await prefs.setString('chat_messages', jsonEncode(allMessages));
      print('💾 Messages saved to local storage');
    } catch (e) {
      print('❌ Error saving messages to local storage: $e');
    }
  }

  // تحميل الرسائل من التخزين المحلي
  Future<void> _loadMessagesFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedMessages = prefs.getString('chat_messages');

      if (savedMessages != null) {
        final Map<String, dynamic> allMessages = jsonDecode(savedMessages);

        for (final entry in allMessages.entries) {
          final List<dynamic> messagesList = entry.value;
          _ticketMessages[entry.key] = messagesList
              .map((msgJson) => ChatMessage.fromJson(msgJson))
              .toList();
        }

        print(
            '📂 Loaded messages from local storage for ${_ticketMessages.keys.length} tickets');
      }
    } catch (e) {
      print('❌ Error loading messages from local storage: $e');
    }
  }

  // تحميل معرف المستخدم الحالي
  Future<void> _loadCurrentUserId() async {
    if (_currentUserId == null) {
      final user = await SharedPreferencesHelper.getUser();
      _currentUserId = user?.id;
    }
  }

  // تعيين التذكرة الحالية وتحميل رسائلها المحفوظة
  Future<void> setCurrentTicket(String ticketId) async {
    if (_currentTicketId != ticketId) {
      print('🔄 Switching to ticket: $ticketId (from: $_currentTicketId)');

      // حفظ الرسائل الحالية للتذكرة السابقة
      if (_currentTicketId != null) {
        _ticketMessages[_currentTicketId!] = List.from(state);
        print(
            '💾 Saved ${state.length} messages for ticket: $_currentTicketId');
        await _saveMessagesToLocal(); // حفظ محلي
      }

      _currentTicketId = ticketId;

      // تحميل الرسائل من التخزين المحلي أولاً
      if (_ticketMessages.isEmpty) {
        await _loadMessagesFromLocal();
      }

      // تحميل الرسائل المحفوظة للتذكرة الجديدة
      if (_ticketMessages.containsKey(ticketId)) {
        state = List.from(_ticketMessages[ticketId]!);
        print('📂 Loaded ${state.length} saved messages for ticket: $ticketId');
      } else {
        state = [];
        print('📝 No saved messages for ticket: $ticketId - starting fresh');
      }
    }
  }

  // التحقق من أن الرسالة تنتمي للتذكرة الحالية
  bool _isMessageForCurrentTicket(ChatMessage message) {
    return _currentTicketId == null || message.ticketId == _currentTicketId;
  }

  // إضافة رسالة جديدة من المستخدم
  Future<void> addMessage(
      String ticketId, ChatMessage message, WidgetRef ref) async {
    await _loadCurrentUserId();

    print('🚀 Starting to send message: ${message.content}');
    print('📋 Ticket ID: $ticketId');
    print('👤 Current User ID: $_currentUserId');

    // إضافة معرف مؤقت للرسالة
    final messageWithId = message.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId ?? '',
      sentAt: DateTime.now().toString(),
      ticketId: ticketId,
    );

    // إضافة الرسالة إلى الحالة المحلية فوراً
    state = [...state, messageWithId];
    print('📝 Message added to local state with ID: ${messageWithId.id}');

    try {
      // إرسال الرسالة عبر SignalR
      await sendMessage(ticketId, messageWithId, ref);
      print('✅ Message sent successfully via SignalR');

      // تحديث حالة الرسالة لتظهر أنها تم إرسالها
      updateMessageStatus(messageWithId.id!, isDelivered: true);
    } catch (e) {
      print('❌ Failed to send message: $e');
      // إزالة الرسالة من الحالة المحلية في حالة الفشل
      state = state.where((msg) => msg.id != messageWithId.id).toList();
      print('🗑️ Message removed from local state due to send failure');
      rethrow;
    }
  }

  // إضافة رسالة مستقبلة من الخادم أو الدعم
  void addReceivedMessage(ChatMessage message) async {
    print('📨 Attempting to add received message: ${message.content}');
    print('🆔 Message ID: ${message.id}');
    print('👤 Sender ID: ${message.senderId}');
    print('🎫 Ticket ID: ${message.ticketId}');
    print('🎯 Current Ticket ID: $_currentTicketId');

    await _loadCurrentUserId();

    // إضافة الرسالة إلى الخريطة المناسبة للتذكرة
    final ticketId = message.ticketId ?? '';
    if (ticketId.isNotEmpty) {
      // إنشاء قائمة جديدة إذا لم تكن موجودة
      if (!_ticketMessages.containsKey(ticketId)) {
        _ticketMessages[ticketId] = [];
      }

      // التحقق من عدم وجود الرسالة مسبقاً في قائمة التذكرة
      final existingIndex =
          _ticketMessages[ticketId]!.indexWhere((msg) => msg.id == message.id);

      if (existingIndex == -1) {
        // إضافة الرسالة إلى قائمة التذكرة
        _ticketMessages[ticketId]!.add(message);
        print('💾 Message saved to ticket $ticketId storage');

        // حفظ محلي فوري للرسائل الجديدة
        _saveMessagesToLocal();

        // إذا كانت الرسالة للتذكرة الحالية، أضفها للحالة المعروضة
        if (ticketId == _currentTicketId) {
          state = [...state, message];
          sortMessagesByDate();
          print('✅ Message added to current view: ${message.content}');
          print('📊 Total messages in current view: ${state.length}');
        } else {
          print(
              '📦 Message stored for ticket $ticketId (not currently active)');
        }

        // إرسال إشعار إذا كانت الرسالة من الدعم الفني
        if (!isMyMessage(message)) {
          print('🔔 رسالة من الدعم الفني - إرسال إشعار');

          await NotificationService().showChatMessageNotification(
            title: 'رسالة جديدة من الدعم الفني',
            body: message.content ?? 'رسالة جديدة',
            ticketId: ticketId,
            senderName: 'فريق الدعم الفني',
          );
        }
      } else {
        // تحديث الرسالة الموجودة
        _ticketMessages[ticketId]![existingIndex] = message;

        // تحديث الحالة المعروضة إذا كانت للتذكرة الحالية
        if (ticketId == _currentTicketId) {
          final currentIndex = state.indexWhere((msg) => msg.id == message.id);
          if (currentIndex != -1) {
            final updatedMessages = [...state];
            updatedMessages[currentIndex] = message;
            state = updatedMessages;
            print('🔄 Message updated in current view: ${message.content}');
          }
        }
      }
    } else {
      print('⚠️ Message ignored - no ticketId provided');
    }
  }

  // تحديث حالة الرسالة (التسليم أو القراءة)
  void updateMessageStatus(String messageId,
      {bool? isDelivered, bool? isRead}) {
    state = state.map((message) {
      if (message.id == messageId) {
        return message.copyWith(
          isDelivered: isDelivered ?? message.isDelivered,
          isRead: isRead ?? message.isRead,
        );
      }
      return message;
    }).toList();
  }

  // تحديث حالة عدة رسائل
  void updateMultipleMessagesStatus(List<String> messageIds,
      {bool? isDelivered, bool? isRead}) {
    state = state.map((message) {
      if (messageIds.contains(message.id)) {
        return message.copyWith(
          isDelivered: isDelivered ?? message.isDelivered,
          isRead: isRead ?? message.isRead,
        );
      }
      return message;
    }).toList();
  }

  // تحديد ما إذا كانت الرسالة من المستخدم الحالي
  bool isMyMessage(ChatMessage message) {
    return message.senderId == _currentUserId;
  }

  // الحصول على آخر رسالة
  ChatMessage? get lastMessage {
    return state.isNotEmpty ? state.last : null;
  }

  // الحصول على عدد الرسائل غير المقروءة
  int get unreadCount {
    return state.where((msg) => !msg.isRead && !isMyMessage(msg)).length;
  }

  // الحصول على الرسائل المصفاة حسب التذكرة
  List<ChatMessage> getMessagesForTicket(String ticketId) {
    return _ticketMessages[ticketId] ?? [];
  }

  // الحصول على التذكرة الحالية
  String? get currentTicketId => _currentTicketId;

  // تعيين قائمة الرسائل (عند تحميل التاريخ)
  void setMessages(List<ChatMessage> messages) {
    print('📋 Setting ${messages.length} messages from server');

    // تجميع الرسائل حسب التذكرة وحفظها
    for (final message in messages) {
      final ticketId = message.ticketId ?? '';
      if (ticketId.isNotEmpty) {
        if (!_ticketMessages.containsKey(ticketId)) {
          _ticketMessages[ticketId] = [];
        }

        // التحقق من عدم وجود الرسالة مسبقاً
        final existingIndex = _ticketMessages[ticketId]!
            .indexWhere((msg) => msg.id == message.id);

        if (existingIndex == -1) {
          _ticketMessages[ticketId]!.add(message);
        } else {
          _ticketMessages[ticketId]![existingIndex] = message;
        }
      }
    }

    // عرض رسائل التذكرة الحالية فقط
    if (_currentTicketId != null &&
        _ticketMessages.containsKey(_currentTicketId!)) {
      state = List.from(_ticketMessages[_currentTicketId!]!);
      print(
          '📋 Displaying ${state.length} messages for current ticket: $_currentTicketId');

      // ترتيب الرسائل حسب التاريخ
      if (state.isNotEmpty) {
        sortMessagesByDate();
      }
    } else {
      state = [];
      print('📋 No messages to display for current ticket: $_currentTicketId');
    }

    print('💾 Total tickets with messages: ${_ticketMessages.keys.length}');
  }

  // إضافة رسائل إلى القائمة الحالية (للتحميل التدريجي)
  void addMessages(List<ChatMessage> messages) {
    print('📋 Adding ${messages.length} messages to storage');

    // إضافة الرسائل إلى التخزين المناسب لكل تذكرة
    for (final message in messages) {
      final ticketId = message.ticketId ?? '';
      if (ticketId.isNotEmpty) {
        if (!_ticketMessages.containsKey(ticketId)) {
          _ticketMessages[ticketId] = [];
        }

        // التحقق من عدم وجود الرسالة مسبقاً
        final existingIndex = _ticketMessages[ticketId]!
            .indexWhere((msg) => msg.id == message.id);

        if (existingIndex == -1) {
          _ticketMessages[ticketId]!.add(message);
        }
      }
    }

    // تحديث الحالة المعروضة للتذكرة الحالية
    if (_currentTicketId != null &&
        _ticketMessages.containsKey(_currentTicketId!)) {
      final currentTicketMessages = _ticketMessages[_currentTicketId!]!;
      final existingIds = state.map((msg) => msg.id).toSet();
      final newMessages = currentTicketMessages
          .where((msg) => !existingIds.contains(msg.id))
          .toList();

      if (newMessages.isNotEmpty) {
        state = [...newMessages, ...state];
        print('📋 Added ${newMessages.length} new messages to current view');
      }
    }
  }

  // مسح جميع الرسائل
  void clearMessages() {
    state = [];
  }

  // ترتيب الرسائل حسب التاريخ
  void sortMessagesByDate() {
    final sortedMessages = [...state];
    sortedMessages.sort((a, b) {
      try {
        DateTime dateA = a.sentAt is String
            ? DateTime.parse(a.sentAt!)
            : a.sentAt as DateTime;
        DateTime dateB = b.sentAt is String
            ? DateTime.parse(b.sentAt!)
            : b.sentAt as DateTime;
        return dateA.compareTo(dateB);
      } catch (e) {
        print('❌ Error sorting messages by date: $e');
        return 0;
      }
    });
    state = sortedMessages;
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
  (ref) => ChatMessagesNotifier(),
);

// final currentMessages = ValueNotifier<List<ChatMessage>>([]);
