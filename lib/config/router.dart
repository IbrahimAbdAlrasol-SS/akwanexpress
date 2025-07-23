import 'package:flutter/material.dart';

/// Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§Ù„ØªÙˆØ¬ÙŠÙ‡
/// Router configuration
class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String deliveryLists = '/delivery-lists';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String support = '/support';
  static const String terms = '/terms';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        // TODO: Ø¥Ø¶Ø§ÙØ© Ø´Ø§Ø´Ø© Ø§Ù„Ø¨Ø¯Ø§ÙŠØ©
        return MaterialPageRoute(builder: (_) => const Placeholder());
      case login:
        // TODO: Ø¥Ø¶Ø§ÙØ© Ø´Ø§Ø´Ø© ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„
        return MaterialPageRoute(builder: (_) => const Placeholder());
      case home:
        // TODO: Ø¥Ø¶Ø§ÙØ© Ø§Ù„Ø´Ø§Ø´Ø© Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©
        return MaterialPageRoute(builder: (_) => const Placeholder());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ø§Ù„ØµÙØ­Ø© ØºÙŠØ± Ù…ÙˆØ¬ÙˆØ¯Ø©: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
