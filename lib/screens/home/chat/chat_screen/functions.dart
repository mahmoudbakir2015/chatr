import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// 🔹 بترجع ID موحد للمحادثة (عشان يفضل نفسه للطرفين)
String getChatId(String myToken, String otherUserId) {
  final ids = [myToken, otherUserId]..sort();
  return ids.join('_');
}

/// 🔹 إرسال رسالة
Future<void> sendMessage({
  required String myToken,
  required String userId,
  required TextEditingController messageController,
}) async {
  final text = messageController.text.trim();
  if (text.isEmpty) return;

  final chatId = getChatId(myToken, userId);
  final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
  final now = FieldValue.serverTimestamp();

  try {
    // ✅ تحديث بيانات المحادثة الرئيسية
    await chatRef.set({
      'participants': [myToken, userId],
      'lastMessage': text,
      'lastTimestamp': now,
    }, SetOptions(merge: true));

    // ✅ إضافة الرسالة
    final msgRef = chatRef.collection('messages').doc();
    await msgRef.set({
      'id': msgRef.id,
      'senderId': myToken,
      'receiverId': userId,
      'message': text,
      'type': 'text',
      'timestamp': now,
    });

    messageController.clear();
  } catch (e) {
    debugPrint("❌ Error sending message: $e");
  }
}
