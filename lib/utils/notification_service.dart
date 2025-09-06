// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:chatr/screens/home/chat/chat_screen/chat_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// تهيئة local notifications وقنوات Android و iOS
  static Future<void> init(BuildContext context) async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    // إنشاء قناة Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'chat_channel',
      'Chat Notifications',
      description: 'Notifications for new chat messages',
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // تهيئة plugin مع onDidReceiveNotificationResponse للضغط على الإشعار
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        handleNotificationTap(context, response.payload);
      },
    );
  }

  /// عرض إشعار محلي
  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'chat_channel',
          'Chat Notifications',
          channelDescription: 'Notifications for new chat messages',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payload = jsonEncode({
      "senderId": message.data['senderId'] ?? '',
      "senderName": message.data['senderName'] ?? 'Unknown',
    });

    await _notificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? "📩 رسالة جديدة",
      message.notification?.body ?? "",
      platformDetails,
      payload: payload,
    );
  }

  /// التعامل مع الضغط على الإشعار
  static void handleNotificationTap(BuildContext context, String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload);
      final senderId = data['senderId'] ?? '';
      final senderName = data['senderName'] ?? 'Unknown';

      if (senderId.isNotEmpty && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(userId: senderId, userName: senderName),
          ),
        );
      }
    } catch (e) {
      log("❌ خطأ في معالجة payload: $e");
    }
  }
}

/// تهيئة Firebase Messaging لجميع حالات التطبيق (Foreground, Background, Terminated)
void setupFirebaseMessaging(BuildContext context) async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await NotificationService.init(context);

  // foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log("📩 رسالة foreground: ${message.notification?.title}");
    NotificationService.showNotification(message);
  });

  // الضغط على إشعار background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    log("📲 المستخدم فتح الإشعار (background)");
    NotificationService.handleNotificationTap(
      context,
      jsonEncode({
        "senderId": message.data['senderId'] ?? '',
        "senderName": message.data['senderName'] ?? 'Unknown',
      }),
    );
  });

  // الضغط على إشعار عندما التطبيق مغلق (terminated)
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    log("📲 المستخدم فتح الإشعار (terminated)");
    NotificationService.handleNotificationTap(
      context,
      jsonEncode({
        "senderId": initialMessage.data['senderId'] ?? '',
        "senderName": initialMessage.data['senderName'] ?? 'Unknown',
      }),
    );
  }
}
