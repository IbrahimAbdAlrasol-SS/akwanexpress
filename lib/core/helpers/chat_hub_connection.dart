import 'dart:async';
import 'package:Tosell/Features/support/providers/chat_provider.dart';
import 'package:Tosell/Features/support/models/chat_message.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/helpers/sharedPreferencesHelper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_core/signalr_core.dart';

HubConnection? chatHubConnection;

// التحقق من حالة الاتصال
bool isSignalRConnected() {
  final isConnected = chatHubConnection?.state == HubConnectionState.connected;
  print(
      '🔍 SignalR connection status: ${isConnected ? "✅ Connected" : "🚫 Not connected"}');
  return isConnected;
}

// إعادة الاتصال إذا لزم الأمر
Future<bool> ensureSignalRConnection(WidgetRef ref) async {
  if (isSignalRConnected()) {
    return true;
  }

  print('🔄 SignalR not connected, attempting to reconnect...');
  try {
    await initSignalRChatConnection(ref);
    return isSignalRConnected();
  } catch (e) {
    print('❌ Failed to reconnect SignalR: $e');
    return false;
  }
}

Future<void> initSignalRChatConnection(WidgetRef ref) async {
  try {
    // التحقق من أن ref لا يزال صالحاً
    ref.read(chatMessagesProvider.notifier);
  } catch (e) {
    print('🚫 Cannot initialize SignalR - ref disposed');
    throw Exception('Widget ref is disposed');
  }

  final user = await SharedPreferencesHelper.getUser();
  if (user?.token == null) {
    print('🚫 Cannot initialize SignalR - no user token available');
    throw Exception('No user token available');
  }

  print(
      '👤 User loaded for SignalR: ${user?.id} - Token: ${user?.token?.substring(0, 20)}...');

  // إذا كان الاتصال موجود ومتصل، لا نحتاج لإعادة الاتصال
  if (chatHubConnection?.state == HubConnectionState.connected) {
    print('🔄 SignalR already connected, setting up listeners');
    _setupChatHistoryListener(ref);
    return;
  }

  // إغلاق الاتصال السابق إن وجد
  if (chatHubConnection != null) {
    print('🔄 Closing existing SignalR connection');
    try {
      await chatHubConnection!.stop();
    } catch (e) {
      print('⚠️ Error stopping previous connection: $e');
    }
    chatHubConnection = null;
  }

  try {
    final chatUrl = imageUrl + 'hubs/chat';
    print('🔗 Connecting to SignalR Chat Hub: $chatUrl');

    chatHubConnection = HubConnectionBuilder()
        .withUrl(
      chatUrl,
      HttpConnectionOptions(
        transport: HttpTransportType.webSockets,
        logging: (level, message) => print('🔗 SignalR Chat: $message'),
        accessTokenFactory: () async {
          print('🔑 Providing access token for SignalR');
          final currentUser = await SharedPreferencesHelper.getUser();
          return currentUser?.token;
        },
        skipNegotiation: false,
        //headers: <String, String>{
        //'Authorization': 'Bearer ${user!.token}',
        //},
      ),
    )
        .withAutomaticReconnect([2000, 5000, 10000, 30000]).build();

    // إضافة مستمعين لأحداث الاتصال
    chatHubConnection!.onclose((error) {
      print('🔴 SignalR connection closed: $error');
    });

    chatHubConnection!.onreconnecting((error) {
      print('🟡 SignalR reconnecting: $error');
    });

    chatHubConnection!.onreconnected((connectionId) {
      print('🟢 SignalR reconnected with ID: $connectionId');
      // إعادة إعداد المستمعين بعد إعادة الاتصال
      try {
        ref.read(chatMessagesProvider.notifier);
        _setupChatHistoryListener(ref);
      } catch (e) {
        print('🚫 Cannot setup listeners after reconnection - ref disposed');
      }
    });

    print('🚀 Starting SignalR connection...');
    await chatHubConnection!.start();
    print('✅ SignalR Chat Connected Successfully');
    print('🔗 Connection ID: ${chatHubConnection!.connectionId}');
    print('🔗 Connection State: ${chatHubConnection!.state}');

    // التحقق مرة أخرى من أن ref لا يزال صالحاً قبل إعداد المستمعين
    try {
      ref.read(chatMessagesProvider.notifier);
      _setupChatHistoryListener(ref);
      print('✅ Chat listeners setup successfully');
    } catch (e) {
      print('🚫 Cannot setup listeners - ref disposed during connection');
      return;
    }

    // الانضمام التلقائي لمجموعة المستخدم العامة
    if (user?.id != null) {
      print('👤 Joining user group: ${user!.id}');
      await joinUserGroup(user.id!);
    }
  } catch (e) {
    print('❌ Failed to connect to SignalR Chat: $e');
    print('❌ Error in initial connection: $e');

    // إذا فشل الاتصال، تنظيف المتغيرات
    if (chatHubConnection != null) {
      try {
        await chatHubConnection!.stop();
      } catch (stopError) {
        print('⚠️ Error stopping failed connection: $stopError');
      }
      chatHubConnection = null;
    }

    rethrow;
  }
}

// الانضمام إلى مجموعة المستخدم العامة
Future<void> joinUserGroup(String userId) async {
  if (chatHubConnection?.state != HubConnectionState.connected) {
    print('🚫 Cannot join user group: SignalR not connected');
    return;
  }

  try {
    await chatHubConnection!.invoke('JoinUserGroup', args: [userId]);
    print('👤 Joined user group: $userId');
  } catch (e, s) {
    print('❌ Failed to join user group: $e');
    print(s);
  }
}

// طلب التذكرة المخصصة للمستخدم الحالي
Future<String?> getUserActiveTicket() async {
  if (chatHubConnection?.state != HubConnectionState.connected) {
    print('🚫 Cannot get user ticket: SignalR not connected');
    return null;
  }

  try {
    final result = await chatHubConnection!.invoke('GetUserActiveTicket');
    if (result != null) {
      print('🎫 User active ticket: $result');
      return result.toString();
    } else {
      print('📝 No active ticket found for user');
      return null;
    }
  } catch (e, s) {
    print('❌ Failed to get user ticket: $e');
    print(s);
    return null;
  }
}

// طلب تاريخ الدردشة لتذكرة معينة
Future<void> requestChatHistory(String ticketId) async {
  print('🚀 Attempting to request chat history for ticket: $ticketId');
  print('🔗 Current connection state: ${chatHubConnection?.state}');

  if (chatHubConnection?.state != HubConnectionState.connected) {
    print('🚫 Cannot request chat history: SignalR not connected');
    return;
  }

  try {
    // تجربة أسماء مختلفة لطلب التاريخ
    final historyMethods = [
      'RequestHistory',
      'GetChatHistory',
      'LoadHistory',
      'GetMessages'
    ];
    Exception? lastException;

    for (final methodName in historyMethods) {
      try {
        print('📞 Trying history method: $methodName with ticketId: $ticketId');
        await chatHubConnection!.invoke(methodName, args: [ticketId]);
        print(
            '✅ Successfully requested chat history using method: $methodName');
        print('⏳ Waiting for LoadChatHistory event...');
        return; // نجح الطلب، اخرج من الدالة
      } catch (e) {
        print('❌ History method $methodName failed: $e');
        lastException = e is Exception ? e : Exception(e.toString());

        if (e.toString().contains('Method does not exist') ||
            e.toString().contains('HubException')) {
          continue;
        } else {
          rethrow;
        }
      }
    }

    // إذا فشلت جميع الطرق
    print('❌ All history methods failed');
    throw lastException ??
        Exception('Failed to request chat history - no available methods');
  } catch (e, s) {
    print('❌ Failed to request chat history: $e');
    print('📍 Stack trace: $s');
  }
}

// الانضمام إلى مجموعة الدردشة
Future<void> joinChatGroup(String ticketId) async {
  print('🚀 Attempting to join chat group for ticket: $ticketId');
  print('🔗 Current connection state: ${chatHubConnection?.state}');

  if (chatHubConnection?.state != HubConnectionState.connected) {
    print('🚫 Cannot join chat group: SignalR not connected');
    return;
  }

  try {
    print('📞 Invoking JoinChatGroup with ticketId: $ticketId');
    await chatHubConnection!.invoke('JoinChatGroup', args: [ticketId]);
    print('✅ Successfully joined chat group for ticket: $ticketId');
  } catch (e, s) {
    print('❌ Failed to join chat group: $e');
    print('📍 Stack trace: $s');
  }
}

// مغادرة مجموعة الدردشة
Future<void> leaveChatGroup(String ticketId) async {
  if (chatHubConnection?.state != HubConnectionState.connected) {
    print('🚫 Cannot leave chat group: SignalR not connected');
    return;
  }

  try {
    await chatHubConnection!.invoke('LeaveChatGroup', args: [ticketId]);
    print('🚪 Left chat group for ticket: $ticketId');
  } catch (e, s) {
    print('❌ Failed to leave chat group: $e');
    print(s);
  }
}

// تحديث حالة قراءة الرسائل
Future<void> markMessagesAsRead(String ticketId) async {
  if (chatHubConnection?.state != HubConnectionState.connected) {
    print('🚫 Cannot mark messages as read: SignalR not connected');
    return;
  }

  try {
    await chatHubConnection!.invoke('MarkMessagesAsRead', args: [ticketId]);
    print('✅ Marked messages as read for ticket: $ticketId');
  } catch (e, s) {
    print('❌ Failed to mark messages as read: $e');
    print(s);
  }
}

void _setupChatHistoryListener(WidgetRef ref) {
  if (chatHubConnection == null) {
    print('🚫 Cannot setup listeners: chatHubConnection is null');
    return;
  }

  print('🔧 Setting up SignalR event listeners...');
  print('🔗 Current connection state: ${chatHubConnection?.state}');

  // إزالة المستمعين السابقين
  chatHubConnection!.off('LoadChatHistory');
  chatHubConnection!.off('ReceiveMessage');
  chatHubConnection!.off('MessageDelivered');
  chatHubConnection!.off('MessageRead');

  print('🗑️ Removed old event listeners');

  // إضافة listener عام لجميع الأحداث للتشخيص
  chatHubConnection!.onreconnected((connectionId) {
    print('🔄 SignalR reconnected with ID: $connectionId');
    print('🔧 Re-setting up listeners after reconnection...');
  });

  // استقبال تاريخ الرسائل
  chatHubConnection!.on('LoadChatHistory', (arguments) {
    print('🔄 LoadChatHistory event received');
    print('📊 Arguments: $arguments');

    if (arguments == null || arguments.isEmpty) {
      print('⚠️ No arguments received for LoadChatHistory');
      return;
    }

    try {
      // التحقق من أن ref لا يزال صالحاً قبل الاستخدام
      final notifier = ref.read(chatMessagesProvider.notifier);

      final List<dynamic> rawList = arguments.first as List<dynamic>;
      print('📋 Raw message count: ${rawList.length}');

      final messages = rawList
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      print('✅ Parsed ${messages.length} chat messages');

      // طباعة معلومات عن التذاكر الموجودة في الرسائل
      final ticketIds = messages.map((m) => m.ticketId).toSet();
      print('🎫 Messages contain tickets: $ticketIds');

      notifier.setMessages(messages);
      print('📩 Successfully loaded ${messages.length} chat messages');
    } catch (e, s) {
      print('❌ Error parsing chat history: $e');
      print('📍 Stack trace: $s');
      // إذا كان الخطأ بسبب ref disposal، تجاهل الحدث
      if (e.toString().contains('disposed')) {
        print('🚫 Ignoring event - widget disposed');
        return;
      }
    }
  });

  chatHubConnection!.on('ReceiveMessage', (arguments) {
    print('🔔 ReceiveMessage event triggered');
    print('📊 Arguments: $arguments');
    print('📊 Arguments type: ${arguments.runtimeType}');
    print('📊 Arguments length: ${arguments?.length}');

    if (arguments == null || arguments.isEmpty) {
      print('⚠️ No arguments received for ReceiveMessage');
      return;
    }

    try {
      // التحقق من أن ref لا يزال صالحاً قبل الاستخدام
      final notifier = ref.read(chatMessagesProvider.notifier);

      final messageData = arguments.first as Map<String, dynamic>;
      print('📋 Raw message data: $messageData');

      final newMessage = ChatMessage.fromJson(messageData);
      print('✅ Message parsed successfully');
      print('📝 Content: ${newMessage.content}');
      print('👤 Sender: ${newMessage.senderId}');
      print('🎫 Ticket: ${newMessage.ticketId}');

      // التحقق من أن الرسالة تحتوي على ticketId
      if (newMessage.ticketId == null || newMessage.ticketId!.isEmpty) {
        print('⚠️ Message ignored - no ticketId provided');
        return;
      }

      notifier.addReceivedMessage(newMessage);
      print('📨 Message added to provider successfully');
    } catch (e, s) {
      print('❌ Error parsing received message: $e');
      print('📍 Stack trace: $s');
      // إذا كان الخطأ بسبب ref disposal، تجاهل الحدث
      if (e.toString().contains('disposed')) {
        print('🚫 Ignoring ReceiveMessage event - widget disposed');
        return;
      }
    }
  });

  // تحديث حالة التسليم
  chatHubConnection!.on('MessageDelivered', (arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      // التحقق من أن ref لا يزال صالحاً قبل الاستخدام
      final notifier = ref.read(chatMessagesProvider.notifier);
      final messageId = arguments.first as String;
      notifier.updateMessageStatus(messageId, isDelivered: true);
      print('✅ Message delivered: $messageId');
    } catch (e) {
      print('❌ Error updating delivery status: $e');
      // إذا كان الخطأ بسبب ref disposal، تجاهل الحدث
      if (e.toString().contains('disposed')) {
        print('🚫 Ignoring MessageDelivered event - widget disposed');
        return;
      }
    }
  });

  // تحديث حالة القراءة
  chatHubConnection!.on('MessageRead', (arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      // التحقق من أن ref لا يزال صالحاً قبل الاستخدام
      final notifier = ref.read(chatMessagesProvider.notifier);
      final messageId = arguments.first as String;
      notifier.updateMessageStatus(messageId, isRead: true);
      print('👁️ Message read: $messageId');
    } catch (e) {
      print('❌ Error updating read status: $e');
      // إذا كان الخطأ بسبب ref disposal، تجاهل الحدث
      if (e.toString().contains('disposed')) {
        print('🚫 Ignoring MessageRead event - widget disposed');
        return;
      }
    }
  });

  print('✅ All SignalR event listeners setup completed');
  print(
      '📡 Listening for: LoadChatHistory, ReceiveMessage, MessageDelivered, MessageRead');

  // إضافة مستمعين لأحداث إضافية محتملة
  print('🔍 Adding additional event listeners...');

  // مستمع لأحداث الرسائل الجديدة بأسماء مختلفة
  final messageEvents = [
    'NewMessage',
    'newMessage',
    'new_message',
    'ChatMessage',
    'chatMessage',
    'chat_message',
    'MessageReceived',
    'messageReceived',
    'message_received',
    'IncomingMessage',
    'incomingMessage',
    'incoming_message',
    'BroadcastMessage',
    'broadcastMessage',
    'broadcast_message'
  ];

  for (final eventName in messageEvents) {
    chatHubConnection!.on(eventName, (arguments) {
      print(
          '🎯 Alternative message event "$eventName" received with args: $arguments');

      if (arguments != null && arguments.isNotEmpty) {
        try {
          // التحقق من أن ref لا يزال صالحاً قبل الاستخدام
          final notifier = ref.read(chatMessagesProvider.notifier);

          final messageData = arguments.first as Map<String, dynamic>;
          final newMessage = ChatMessage.fromJson(messageData);

          print('✅ Alternative message parsed: ${newMessage.content}');
          notifier.addReceivedMessage(newMessage);
        } catch (e) {
          print('❌ Error parsing alternative message event: $e');
          if (e.toString().contains('disposed')) {
            print('🚫 Ignoring alternative event - widget disposed');
            return;
          }
        }
      }
    });
  }

  // مستمع عام لجميع الأحداث للتشخيص
  print('🔍 Adding debug listeners for diagnostic purposes...');

  final debugEvents = [
    'UserJoined',
    'UserLeft',
    'TypingStarted',
    'TypingStopped',
    'ConnectionEstablished',
    'GroupJoined',
    'GroupLeft'
  ];

  for (final eventName in debugEvents) {
    chatHubConnection!.on(eventName, (arguments) {
      print('🎯 DEBUG: Event "$eventName" received with args: $arguments');
    });
  }
}

Future<void> sendMessage(
    String ticketId, ChatMessage message, WidgetRef ref) async {
  print('🚀 Attempting to send message via SignalR');
  print('🔗 Connection state: ${chatHubConnection?.state}');

  // التحقق من الاتصال وإعادة المحاولة إذا لزم الأمر
  if (!await ensureSignalRConnection(ref)) {
    print('🚫 Cannot send message: Failed to establish SignalR connection');
    throw Exception('SignalR connection not established');
  }

  try {
    final user = await SharedPreferencesHelper.getUser();
    if (user?.id == null) {
      throw Exception('User not found or not logged in');
    }

    print('👤 User loaded: ${user?.id}');

    // تجربة أسماء مختلفة للدوال المتاحة على الخادم
    final methodNames = ['SendChatMessage', 'SendMessage', 'Send'];
    Exception? lastException;

    for (final methodName in methodNames) {
      try {
        print('🔄 Trying method: $methodName');

        // الخادم يتوقع معاملات: ticketId, content, attachments
        final args = [
          ticketId,
          message.content,
          message.attachmentsUrl ?? [],
        ];

        print('📤 Sending message with method: $methodName');
        print('📤 Args: $args');

        await chatHubConnection!.invoke(methodName, args: args);

        print('✅ Message sent successfully using method: $methodName');
        print('📝 Content: ${message.content}');
        print('👤 Sender: ${user?.id}');
        print('🎫 Ticket: $ticketId');
        return; // نجح الإرسال، اخرج من الدالة
      } catch (e) {
        print('❌ Method $methodName failed: $e');
        lastException = e is Exception ? e : Exception(e.toString());

        // إذا كان الخطأ "Method does not exist"، جرب الطريقة التالية
        if (e.toString().contains('Method does not exist') ||
            e.toString().contains('HubException')) {
          continue;
        } else {
          // خطأ آخر غير متعلق بوجود الدالة
          rethrow;
        }
      }
    }

    // إذا فشلت جميع الطرق
    print('❌ All send methods failed');
    throw lastException ??
        Exception('Failed to send message - no available methods');
  } catch (e, s) {
    print('❌ Failed to send message: $e');
    print('📍 Stack trace: $s');
    rethrow;
  }
}
