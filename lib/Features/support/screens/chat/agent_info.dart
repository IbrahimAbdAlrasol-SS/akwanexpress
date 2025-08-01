import 'package:flutter/material.dart';

class AgentInfo extends StatelessWidget {
  const AgentInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Image.asset('assets/images/blue logo.png', height: 60),
        const SizedBox(height: 12),
        const Text(
          'الدعم الفني',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          'يتم الرد خلال 5 دقائق',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
