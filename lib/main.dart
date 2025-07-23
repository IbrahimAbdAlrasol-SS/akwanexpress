import 'package:flutter/material.dart';
import 'config/router.dart';
import 'config/di.dart';
import 'core/theme/app_theme.dart';

void main() {
  DependencyInjection.init();
  runApp(const AkwanExpressApp());
}

class AkwanExpressApp extends StatelessWidget {
  const AkwanExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ø£ÙƒÙˆØ§Ù† Ø¥ÙƒØ³Ø¨Ø±ÙŠØ³',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.splash,
      
      locale: const Locale('ar', 'SA'),
      debugShowCheckedModeBanner: false,
    );
  }
}
