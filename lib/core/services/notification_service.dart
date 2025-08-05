import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'chat_messages';
  static const String _channelName = 'رسائل الدردشة';
  static const String _channelDescription =
      'إشعارات الرسائل الجديدة من الدعم الفني';

  Future<void> initialize() async {
    // طلب إذن الإشعارات
    await _requestNotificationPermission();

    // إعداد الإشعارات للأندرويد
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعداد الإشعارات للـ iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // إنشاء قناة الإشعارات للأندرويد
    await _createNotificationChannel();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isDenied) {
      print('⚠️ تم رفض إذن الإشعارات');
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      // vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showChatMessageNotification({
    required String title,
    required String body,
    required String ticketId,
    String? senderName,
  }) async {
    try {
      // سيتم استخدام الصوت الافتراضي للنظام من خلال إعدادات الإشعار

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF034EC9),
        enableVibration: true,
        // vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),

        styleInformation: BigTextStyleInformation(''),
        autoCancel: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.wav',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final String notificationTitle = senderName != null
          ? 'رسالة جديدة من $senderName'
          : 'رسالة جديدة من الدعم الفني';

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        notificationTitle,
        body,
        platformChannelSpecifics,
        payload: 'chat_$ticketId',
      );

      print('🔔 تم إرسال إشعار الرسالة الجديدة');
    } catch (e) {
      print('❌ خطأ في إرسال الإشعار: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null && payload.startsWith('chat_')) {
      final String ticketId = payload.substring(5);
      print('🔔 تم النقر على إشعار الدردشة للتذكرة: $ticketId');
      // يمكن إضافة منطق للانتقال إلى شاشة الدردشة هنا
    }
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
