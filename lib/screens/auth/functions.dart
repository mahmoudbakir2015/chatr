import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> updateUserToken(String uid) async {
  try {
    final users = FirebaseFirestore.instance.collection("users");

    // الحصول على FCM Token الجديد
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      await users.doc(uid).update({
        "fcmToken": fcmToken,
        "updatedAt": FieldValue.serverTimestamp(),
      });
      debugPrint("✅ User token updated for $uid");
    } else {
      debugPrint("⚠️ Failed to get FCM token");
    }
  } catch (e) {
    debugPrint("❌ Error updating user token: $e");
  }
}
