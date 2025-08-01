import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/theme/app_theme.dart';
import 'package:Tosell/core/helpers/sharedPreferencesHelper.dart';
import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:Tosell/core/helpers/chat_hub_connection.dart';
import 'package:Tosell/core/helpers/hubConnection.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Optional: Use this if you need to override certificate checks for dev APIs
  // HttpOverrides.global = MyHttpOverrides();

  // 🟢 OneSignal Init
  OneSignal.initialize("05ccd9f6-8cee-4750-a52c-46daba72fdc1");
  OneSignal.Notifications.requestPermission(true);

  // Setup click listener
  OneSignal.Notifications.addClickListener((event) {
    final title = event.notification.title;
    final data = event.notification.additionalData;
    debugPrint('🟢 Notification Clicked: $title, Data: $data');
    // TODO: Handle route navigation if needed
  });

  // Determine start route
  final token = (await SharedPreferencesHelper.getUser())?.token;
  initialLocation = token == null ? AppRoutes.login : AppRoutes.vipHome;

  // SignalR initialization
  final container = ProviderContainer();
  await initSignalRConnection(container);
  await startSendingLiveLocation();
  await invokeNearbyShipment();

  // Run app
  runApp(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (context, child) => EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/lang',
          startLocale: const Locale("ar"),
          fallbackLocale: const Locale('ar'),
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();

    // Show in-app dialog for foreground notifications
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final title = event.notification.title;
      final body = event.notification.body;

      debugPrint('📩 Foreground Notification: $title - $body');

      event.preventDefault(); // prevent system notification

      // Show dialog with context after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title ?? 'تنبيه'),
            content: Text(body ?? 'لديك إشعار جديد'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tosell',
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
