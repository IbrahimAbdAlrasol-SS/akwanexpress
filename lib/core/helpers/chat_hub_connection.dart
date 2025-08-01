import 'dart:async';
import 'package:Tosell/Features/support/providers/chat_provider.dart';
import 'package:Tosell/Features/support/models/chat_message.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/helpers/sharedPreferencesHelper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_core/signalr_core.dart';

late HubConnection hubConnection;

Future<void> initSignalRChatConnection(WidgetRef ref) async {
  final user = await SharedPreferencesHelper.getUser();

  if (hubConnection.state == HubConnectionState.connected) return;

  hubConnection = HubConnectionBuilder()
      .withUrl(
        imageUrl + 'hubs/chat',
        HttpConnectionOptions(
          transport: HttpTransportType.webSockets,
          logging: (level, message) => print(message),
          accessTokenFactory: () async => user?.token,
        ),
      )
      .withAutomaticReconnect()
      .build();

  await hubConnection.start();

  print('✅ SignalR Chat Connected');

  _setupChatHistoryListener(ref);
}

void _setupChatHistoryListener(WidgetRef ref) {
  final notifier = ref.read(chatMessagesProvider.notifier);

  hubConnection.off('LoadChatHistory');

  hubConnection.on('LoadChatHistory', (arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final List<dynamic> rawList = arguments.first as List<dynamic>;
      final messages = rawList
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      notifier.setMessages(messages);
      print('📩 Loaded ${messages.length} chat messages');
    } catch (e) {
      print('❌ Error parsing chat history: $e');
    }
  });
}

Future<void> sendMessage(String ticketId, ChatMessage message) async {
  if (hubConnection?.state != HubConnectionState.connected) {
    print('🚫 Cannot send message: SignalR not connected');
    return;
  }

  try {
    await hubConnection.invoke('SendMessage', args: [
      ticketId,
      message.content,
      message.attachmentsUrl,
    ]);
    print('✅ Message sent');
  } catch (e, s) {
    print('❌ Failed to send message: $e');
    print(s);
  }
}
