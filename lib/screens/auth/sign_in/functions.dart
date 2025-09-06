// ignore_for_file: use_build_context_synchronously
import 'package:chatr/screens/auth/sign_up/sign_up.dart';
import 'package:chatr/screens/home/home.dart';
import 'package:chatr/utils/notification_service.dart';
import 'package:chatr/utils/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> submit({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required String emailAddress,
  required String password,
}) async {
  if (formKey.currentState!.validate()) {
    await loginWithEmailAndPassword(
      context: context,
      emailAddress: emailAddress,
      password: password,
    );
  }
}

void goToSignUp({required BuildContext context}) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("👉 Go to Sign Up Page")));
  }
}

Future<void> loginWithEmailAndPassword({
  required String emailAddress,
  required String password,
  required BuildContext context,
}) async {
  try {
    final userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailAddress, password: password);

    final user = userCredential.user;
    if (user == null) throw Exception("User not found after login.");

    // 🔹 الحصول على FCM Token الحالي للجهاز
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint("🔑 FCM Token: $token");

    if (token != null && token.isNotEmpty) {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      // 🔹 إزالة التوكن القديم من أي حسابات أخرى على نفس الجهاز
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('fcmTokens', arrayContains: token)
          .get();

      for (var doc in querySnapshot.docs) {
        if (doc.id != user.uid) {
          await doc.reference.update({
            "fcmTokens": FieldValue.arrayRemove([token]),
          });
        }
      }

      // 🔹 إضافة التوكن الحالي للحساب الحالي
      await userDoc.set({
        "fcmTokens": FieldValue.arrayUnion([token]),
      }, SetOptions(merge: true));
    }

    // 🔹 حفظ UID محليًا
    await TokenStorage.saveToken(user.uid);

    // 🔹 تهيئة Notifications فور تسجيل الدخول
    NotificationService.init(context);
    setupFirebaseMessaging(context);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Login Successful")));

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const Home()));
    }

    debugPrint("✅ User logged in: ${user.uid}");
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'user-not-found') {
      errorMessage = "⚠️ No user found for that email.";
    } else if (e.code == 'wrong-password') {
      errorMessage = "⚠️ Wrong password provided.";
    } else {
      errorMessage = "❌ Login Failed: ${e.message}";
    }

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }

    debugPrint(errorMessage);
  } catch (e) {
    debugPrint("❌ Error in loginWithEmailAndPassword: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Something went wrong. Try again.")),
      );
    }
  }
}
