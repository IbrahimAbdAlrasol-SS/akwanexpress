import 'dart:io';
import 'dart:async';
import 'package:Tosell/core/helpers/SharedPreferencesHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/theme/app_theme.dart';
import 'package:Tosell/core/services/notification_service.dart';
import 'package:Tosell/Features/home/providers/nearby_shipments_provider.dart';
import 'package:Tosell/core/helpers/chat_hub_connection.dart';
import 'package:Tosell/core/helpers/hubConnection.dart';
import 'package:Tosell/core/helpers/hubMethods.dart';

Timer? _periodicUpdateTimer;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  OneSignal.initialize("05ccd9f6-8cee-4750-a52c-46daba72fdc1");
  OneSignal.Notifications.requestPermission(true);
  OneSignal.Notifications.addClickListener((event) {
    final title = event.notification.title;
    final data = event.notification.additionalData;
    debugPrint('🟢 Notification Clicked: $title, Data: $data');
  });

  await NotificationService().initialize();

  final token = (await SharedPreferencesHelper.getUser())?.token;
  initialLocation = token == null ? AppRoutes.login : AppRoutes.vipHome;
  final container = ProviderContainer();
  await initSignalRConnection(container);
  await startSendingLiveLocation();
  await invokeNearbyShipment();

  _startPeriodicUpdate();
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

void _startPeriodicUpdate() {
  _periodicUpdateTimer =
      Timer.periodic(const Duration(seconds: 5), (timer) async {
    try {
      print('🔄 تحديث دوري للطلبات...');
      await invokeNearbyShipment();
    } catch (e) {
      print('❌ خطأ في التحديث الدوري: $e');
    }
  });
}

void _stopPeriodicUpdate() {
  _periodicUpdateTimer?.cancel();
  _periodicUpdateTimer = null;
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

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      final title = event.notification.title;
      final body = event.notification.body;
      debugPrint('📩 Foreground Notification: $title - $body');
      event.preventDefault();
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
