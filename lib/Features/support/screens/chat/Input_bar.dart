import 'package:Tosell/Features/support/models/chat_message.dart';
import 'package:Tosell/core/helpers/sharedPreferencesHelper.dart';
import 'package:flutter/material.dart';

class InputBar extends StatefulWidget {
  final String ticketId;
  final Future<void> Function(String, ChatMessage) onSend;

  const InputBar({super.key, required this.onSend, required this.ticketId});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) {
      print('⚠️ Cannot send: text empty or already loading');
      return;
    }

    print('🚀 Starting to send message from InputBar: $text');

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await SharedPreferencesHelper.getUser();
      print('👤 User loaded in InputBar: ${user?.id}');

      var message = ChatMessage(
        id: '', // سيتم تعيينه في المزود
        content: text,
        attachmentsUrl: [],
        senderId: user?.id ?? '',
        sentAt: DateTime.now().toString(),
        ticketId: widget.ticketId,
        isDelivered: false,
        isRead: false,
      );

      print('📝 Message created: ${message.content}');
      print('🎫 Ticket ID: ${widget.ticketId}');

      // مسح النص فوراً لتحسين تجربة المستخدم
      _controller.clear();

      // إرسال الرسالة
      await widget.onSend(widget.ticketId, message);

      print('✅ Message sent successfully from InputBar');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الرسالة بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error sending message from InputBar: $e');

      // إعادة النص في حالة الفشل
      _controller.text = text;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إرسال الرسالة: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: _handleSend,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                // TODO: إضافة وظيفة التسجيل الصوتي
              },
              icon: const Icon(Icons.mic_none, color: Colors.blue),
            ),
            IconButton(
              onPressed: () {
                // TODO: إضافة وظيفة اختيار الصور
              },
              icon: const Icon(Icons.image_outlined, color: Colors.blue),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالتك هنا...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _handleSend(),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                onPressed: _handleSend,
                icon: const Icon(Icons.send, color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
