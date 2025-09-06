// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:chatr/screens/home/home.dart';
import 'package:chatr/utils/services.dart';
import 'package:chatr/utils/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// 🔹 استدعاء عند الضغط على زرار SignUp
Future<void> submit({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required String emailAddress,
  required String password,
  required String name,
}) async {
  if (formKey.currentState!.validate()) {
    await signUpWithEmailAndPassword(
      emailAddress: emailAddress,
      password: password,
      name: name,
      context: context,
    );
  }
}

/// 🔹 تسجيل مستخدم جديد
Future<void> signUpWithEmailAndPassword({
  required String emailAddress,
  required String password,
  required BuildContext context,
  required String name,
}) async {
  try {
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: emailAddress,
          password: password,
        );

    final user = userCredential.user;
    if (user == null) throw Exception("User creation failed");

    // 🔹 إضافة المستخدم في Firestore مع دعم Multi-device FCM
    await addUserToDatabase(
      name: name,
      email: emailAddress,
      uid: user.uid,
      context: context,
    );

    // 🔹 حفظ UID محليًا
    await TokenStorage.saveToken(user.uid);

    // 🔹 تهيئة Notifications فور تسجيل الدخول
    NotificationService.init(context);
    setupFirebaseMessaging(context);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Sign Up Successful")));

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const Home()));
    }

    log("✅ User signed up: ${user.uid}");
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'weak-password') {
      errorMessage = "⚠️ The password provided is too weak.";
    } else if (e.code == 'email-already-in-use') {
      errorMessage = "⚠️ The account already exists for that email.";
    } else {
      errorMessage = "❌ Sign Up Failed: ${e.message}";
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
    log(errorMessage);
  } catch (e) {
    log("❌ Error in signUpWithEmailAndPassword: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Something went wrong. Try again.")),
      );
    }
  }
}

/// 🔹 إضافة المستخدم لقاعدة البيانات مع دعم Multi-device FCM Tokens
Future<void> addUserToDatabase({
  required String name,
  required String email,
  required String uid,
  required BuildContext context,
}) async {
  try {
    final users = FirebaseFirestore.instance.collection("users");

    // 🔹 الحصول على FCM Token الحالي للجهاز
    final fcmToken = await FirebaseMessaging.instance.getToken();

    await users.doc(uid).set({
      "name": name.trim().toLowerCase(),
      "uid": uid,
      "email": email.trim(),
      "fcmTokens": fcmToken != null ? FieldValue.arrayUnion([fcmToken]) : [],
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint("✅ User added to Firestore with token: $uid");
  } catch (e) {
    debugPrint("❌ Failed to add user: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to add user: $e")));
    }
  }
}
