import 'dart:developer';
import 'package:chatr/screens/auth/sign_in/sign_in.dart';
import 'package:chatr/screens/home/home.dart';
import 'package:chatr/utils/notification_service.dart';
import 'package:chatr/utils/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// 🔹 Handler للرسائل في الخلفية
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("🔔 Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🔹 استقبال رسائل في الخلفية
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 استرجاع التوكن المخزن (لو موجود)
  String? token = await TokenStorage.getToken();

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    log(token.toString(), name: 'main');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatr',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Builder(
        builder: (context) {
          // 🔹 تهيئة Local Notifications + Firebase Messaging
          setupFirebaseMessaging(context);

          // 🔹 تحديد الشاشة الأساسية
          return token != null ? const Home() : const SignInScreen();
        },
      ),
    );
  }
}
