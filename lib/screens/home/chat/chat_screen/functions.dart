import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// 👇 أنشئ chatId ثابت بين الاتنين
String getChatId(String myId, String otherId) {
  return myId.hashCode <= otherId.hashCode
      ? "${myId}_$otherId"
      : "${otherId}_$myId";
}

// 👇 send message to Firestore
// 🟢 sendMessage
void sendMessage({
  required String myToken,
  required String userId,
  required TextEditingController messageController,
}) async {
  if (messageController.text.trim().isEmpty) return;

  String chatId = getChatId(myToken, userId);

  await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .add({
        'senderId': myToken,
        'receiverId': userId,
        'message': messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

  messageController.clear();
}
