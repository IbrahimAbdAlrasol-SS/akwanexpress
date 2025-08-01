import 'package:Tosell/Features/support/models/chat_message.dart';
import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final String ticketId;
  final void Function(String, ChatMessage) onSend;

  const InputBar({super.key, required this.onSend, required this.ticketId});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    var message = ChatMessage(
      content: text,
      attachmentsUrl: [],
    );
    widget.onSend(widget.ticketId, message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            const Icon(Icons.mic_none, color: Colors.blue),
            const SizedBox(width: 8),
            const Icon(Icons.image_outlined, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالتك هنا',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            IconButton(
              onPressed: _handleSend,
              icon: const Icon(Icons.send, color: Colors.blue),
            )
          ],
        ),
      ),
    );
  }
}
