import 'package:Tosell/Features/support/services/message_service.dart';
import 'package:Tosell/core/helpers/chat_hub_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super([]);
  MessageService _servce = MessageService();

  void addMessage(String ticketId, ChatMessage message) {
    sendMessage(ticketId, message);
    state = [...state, message];
    //TODO: send message Logic
  }

  void setMessages(List<ChatMessage> messages) {
    state = messages;
  }

  void clearMessages() {
    state = [];
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
  (ref) => ChatMessagesNotifier(),
);

// final currentMessages = ValueNotifier<List<ChatMessage>>([]);
