import 'package:Tosell/Features/support/providers/chat_provider.dart';
import 'package:Tosell/Features/support/screens/chat/Input_bar.dart';
import 'package:Tosell/Features/support/screens/chat/agent_info.dart';
import 'package:Tosell/Features/support/screens/chat/chat_header.dart';
import 'package:Tosell/Features/support/screens/chat/chat_message_bubble.dart';
import 'package:Tosell/core/helpers/chat_hub_connection.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportChatScreen extends ConsumerStatefulWidget {
  final String ticketId;
  const SupportChatScreen({super.key, required this.ticketId});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  @override
  void initState() {
    initialConnection();
    super.initState();
  }

  Future<void> initialConnection() async =>
      await initSignalRChatConnection(ref);

  @override
  @override
  void dispose() {
    hubConnection.stop();

    ref.read(chatMessagesProvider.notifier).clearMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final notifier = ref.read(chatMessagesProvider.notifier);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.colorScheme.primary.withOpacity(0.05),
        body: Column(
          children: [
            const ChatHeader(),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return const AgentInfo();
                  final msg = messages[index - 1];
                  return ChatMessageBubble(
                    message: msg.content ?? 'لا توجد رسالة',
                    time: msg.sentAt ?? 'غير معروف',
                    imageUrl: msg.attachmentsUrl?.firstOrNull ?? '',
                    isMe: true,
                  );
                },
              ),
            ),
            InputBar(ticketId: widget.ticketId, onSend: notifier.addMessage),
          ],
        ),
      ),
    );
  }
}
