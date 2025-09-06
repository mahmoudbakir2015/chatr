// ignore_for_file: use_build_context_synchronously

import 'package:chatr/screens/auth/sign_in/sign_in.dart';
import 'package:chatr/utils/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> signOut(BuildContext context) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 🟢 الحصول على FCM Token الحالي للجهاز
      final token = await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        // 🛑 إزالة التوكن الحالي من حساب المستخدم في Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
              "fcmTokens": FieldValue.arrayRemove([token]),
            });
      }
    }

    // 🟢 تسجيل الخروج من FirebaseAuth
    await FirebaseAuth.instance.signOut();

    // 🟢 مسح أي بيانات محلية إذا كانت موجودة
    await TokenStorage.clearToken();

    // 🟢 إعادة التوجيه لشاشة تسجيل الدخول
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );

      // ✅ عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Logged out successfully")),
      );
    }
  } catch (error) {
    // ❌ عرض رسالة خطأ
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error logging out: $error")));
    }
  }
}
