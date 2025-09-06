import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';

/// 🔹 بترجع ID موحد للمحادثة (عشان يفضل نفسه للطرفين)
String getChatId(String myId, String otherUserId) {
  final ids = [myId, otherUserId]..sort();
  return ids.join('_');
}

/// 🔹 إرسال رسالة
Future<void> sendMessage({
  required String myId,
  required String otherUserId,
  required TextEditingController messageController,
}) async {
  final text = messageController.text.trim();
  if (text.isEmpty) return;

  final chatId = getChatId(myId, otherUserId);
  final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
  final now = FieldValue.serverTimestamp();

  try {
    // ✅ تحديث بيانات المحادثة الرئيسية
    await chatRef.set({
      'participants': [myId, otherUserId],
      'lastMessage': text,
      'lastTimestamp': now,
    }, SetOptions(merge: true));

    // ✅ إضافة الرسالة
    final msgRef = chatRef.collection('messages').doc();
    await msgRef.set({
      'id': msgRef.id,
      'senderId': myId,
      'receiverId': otherUserId,
      'message': text,
      'type': 'text',
      'timestamp': now,
    });

    // 🟢 استدعاء إرسال الإشعار للمستقبل فقط
    await sendPushMessage(
      receiverId: otherUserId,
      senderId: myId,
      message: text,
    );

    messageController.clear();
  } catch (e) {
    debugPrint("❌ Error sending message: $e");
  }
}

/// 🔹 إرسال الإشعار لمستخدم (يدعم multi-device)
Future<void> sendPushMessage({
  required String receiverId,
  required String senderId,
  required String message,
}) async {
  try {
    // 📌 جيب بيانات المستقبل من Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();

    if (!userDoc.exists || userDoc['fcmTokens'] == null) {
      debugPrint("⚠️ No FCM tokens for user: $receiverId");
      return;
    }

    // 🔹 قائمة التوكنز (multi-device support)
    final tokens = List<String>.from(userDoc['fcmTokens'] ?? []);

    if (tokens.isEmpty) {
      debugPrint("⚠️ No tokens found for user: $receiverId");
      return;
    }

    // 📂 اقرأ ملف service-account.json
    final serviceAccountJson = await rootBundle.loadString(
      'assets/service_account.json',
    );
    final serviceAccount = json.decode(serviceAccountJson);

    // 🎫 Credentials
    final accountCredentials = ServiceAccountCredentials.fromJson(
      serviceAccount,
    );

    // 🎯 Scopes
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // 🔑 Auth client
    final client = await clientViaServiceAccount(accountCredentials, scopes);

    // 🆔 Project ID من ملف JSON
    final projectId = serviceAccount['project_id'];

    // 🔁 ابعت الإشعار لكل توكن نشط للمستقبل فقط
    for (final token in tokens) {
      await _sendNotificationToToken(
        client: client,
        projectId: projectId,
        token: token,
        senderId: senderId,
        message: message,
      );
    }

    client.close();
  } catch (e) {
    debugPrint("❌ Error sending push message: $e");
  }
}

/// 🔹 دالة داخلية تبعت إشعار لتوكن واحد
Future<void> _sendNotificationToToken({
  required AuthClient client,
  required String projectId,
  required String token,
  required String senderId,
  required String message,
}) async {
  final url = Uri.parse(
    'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
  );

  final bodyData = {
    "message": {
      "token": token,
      "notification": {"title": "📩 رسالة جديدة", "body": message},
      "data": {"senderId": senderId, "message": message},
    },
  };

  final response = await client.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(bodyData),
  );

  debugPrint(
    "📨 Push response [${token.substring(0, 10)}...]: "
    "${response.statusCode} - ${response.body}",
  );
}
