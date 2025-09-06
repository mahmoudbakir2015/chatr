import 'dart:developer';
import 'package:chatr/screens/onboard/onboard.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chatr/utils/services.dart';
import 'package:chatr/screens/home/home.dart';
import 'package:chatr/const/api_key.dart';
import 'package:chatr/utils/notification_service.dart';

// 🔹 Background handler (Android/iOS)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("🔔 Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Init Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDQWBy-5T12kkzmsw_cKPo-dntnLsYVcMs",
        authDomain: "chatr-dd82f.firebaseapp.com",
        projectId: "chatr-dd82f",
        storageBucket: "chatr-dd82f.firebasestorage.app",
        messagingSenderId: "590015773117",
        appId: "1:590015773117:web:d52bb5218822210b19bad4",
        measurementId: "G-GH0LE3PEY1",
      ),
    );

    // 🔹 Web Auth persistence
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } else {
    await Firebase.initializeApp();
  }

  // 🔹 Background messages handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 تسجيل دخول مؤقت أو استرجاع التوكن
  User? user = FirebaseAuth.instance.currentUser;

  String? token;

  if (kIsWeb) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log("🔔 User granted permission for notifications");

      // تأكد أن المستخدم مسجل دخول
      if (user != null) {
        token = await messaging.getToken(vapidKey: vapidkey);
        log('🔑 Web FCM Token: $token');
        await TokenStorage.saveToken(token!);
      } else {
        log("❌ User not signed in on Web, cannot fetch token");
      }
    } else {
      log("❌ User declined notifications");
    }
  } else {
    token = await TokenStorage.getToken();
  }

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
          setupFirebaseMessaging(context);
          // 🔹 عرض الصفحة المناسبة حسب تسجيل الدخول
          return FirebaseAuth.instance.currentUser != null
              ? const Home()
              : const OnboardingScreen();
        },
      ),
    );
  }
}
