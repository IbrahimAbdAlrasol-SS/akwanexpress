import 'package:flutter/material.dart';

/// Ø´Ø§Ø´Ø© Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø­Ø³Ø§Ø¨
/// Registration screen
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ø¥Ù†Ø´Ø§Ø¡ Ø­Ø³Ø§Ø¨'),
      ),
      body: const Center(
        child: Text('Ø´Ø§Ø´Ø© Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø­Ø³Ø§Ø¨'),
      ),
    );
  }
}
