import 'dart:developer';
import 'package:chatr/screens/home/chat/chat_screen/functions.dart';
import 'package:chatr/screens/home/chat/chat_screen/items.dart';
import 'package:chatr/utils/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({super.key, required this.userId, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ValueNotifier<bool> _canSend = ValueNotifier(false);

  String? myToken;

  @override
  void initState() {
    _loadToken();
    _messageController.addListener(() {
      _canSend.value = _messageController.text.trim().isNotEmpty;
    });
    super.initState();
  }

  Future<void> _loadToken() async {
    String? token = await TokenStorage.getToken();
    setState(() {
      myToken = token;
    });
    log(token.toString(), name: 'chat token');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _canSend.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (myToken == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == myToken;

                    return MessageBubble(
                      text: msg['message'] ?? "",
                      isMe: isMe,
                      timestamp: (msg['timestamp'] as Timestamp?)?.toDate(),
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
                  ValueListenableBuilder<bool>(
                    valueListenable: _canSend,
                    builder: (context, canSend, _) {
                      return IconButton(
                        icon: const Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: canSend
                            ? () {
                                sendMessage(
                                  myToken: myToken!,
                                  userId: widget.userId,
                                  messageController: _messageController,
                                );
                              }
                            : null,
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
