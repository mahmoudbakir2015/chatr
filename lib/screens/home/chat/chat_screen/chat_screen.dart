import 'dart:developer';
import 'package:chatr/screens/home/chat/chat_screen/functions.dart';
import 'package:chatr/utils/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String userId; // 🔥 الـ uid بتاع الشخص اللي هتتكلم معاه
  final String userName; // 🔥 اسم الشخص اللي ظاهر في العنوان

  const ChatScreen({super.key, required this.userId, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? myToken;

  @override
  void initState() {
    _loadToken();
    super.initState();
  }

  // 👇 dispose controller
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    String? token = await TokenStorage.getToken();
    setState(() {
      myToken = token;
    });
    log(token.toString(), name: 'chat token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.userName}")),
      body: Column(
        children: [
          // 🟢 الرسائل
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(getChatId(myToken!, widget.userId))
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // 🔄 يخلي الرسائل الجديدة تحت
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == myToken; // 🔥

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg['message'] ?? ""),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🟢 خانة كتابة الرسالة
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () {
                      sendMessage(
                        myToken: myToken!,
                        userId: widget.userId,
                        messageController: _messageController,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
