import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await localNotifications.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'frostiqalerts',
      'FrostIQ Alerts',
      description: 'Critical alerts from your Frostiq device',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(
          title: message.notification!.title ?? 'FrostIQ Alert',
          body: message.notification!.body ?? '',
          type: AlertType.warning,
        );
      }
    });

    String? token = await messaging.getToken();
    print('FCM Token: $token');
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    AlertType type = AlertType.info,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'frostiqalerts',
      'FrostIQ Alerts',
      channelDescription: 'Critical alerts from your Frostiq device',
      importance: Importance.max,
      priority: Priority.high,
      color: getColorForType(type),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(body),
      enableLights: true,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await localNotifications.show(id, title, body, details);
  }

  static Color getColorForType(AlertType type) {
    switch (type) {
      case AlertType.critical: return Colors.red;
      case AlertType.warning:  return Colors.orange;
      case AlertType.info:     return Colors.blue;
    }
  }
}

enum AlertType { critical, warning, info }