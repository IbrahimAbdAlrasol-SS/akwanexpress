import 'package:flutter/material.dart';

/// Ø¨Ø·Ø§Ù‚Ø© Ø§Ù„Ø·Ù„Ø¨
/// Order card widget
class OrderCard extends StatelessWidget {
  const OrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Ø·Ù„Ø¨ #12345'),
        subtitle: const Text('ÙÙŠ Ø§Ù„Ø·Ø±ÙŠÙ‚'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Ø§Ù„Ø§Ù†ØªÙ‚Ø§Ù„ Ù„ØªÙØ§ØµÙŠÙ„ Ø§Ù„Ø·Ù„Ø¨
        },
      ),
    );
  }
}
