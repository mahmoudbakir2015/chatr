import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatr/screens/home/chat/chat_screen/chat_screen.dart';
import 'package:chatr/utils/services.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  String? myToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    String? token = await TokenStorage.getToken();
    setState(() {
      myToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (myToken == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: myToken)
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No data available"));
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("No chats yet"));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatData = chat.data() as Map<String, dynamic>?;

              if (chatData == null) {
                return const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.error)),
                  title: Text("Invalid chat data"),
                );
              }

              final participants = List<String>.from(
                chatData['participants'] ?? [],
              );

              // البحث عن المستخدم الآخر في المحادثة
              String? otherUserId;
              for (final id in participants) {
                if (id != myToken) {
                  otherUserId = id;
                  break;
                }
              }

              if (otherUserId == null || otherUserId.isEmpty) {
                return const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.error)),
                  title: Text("Invalid participant"),
                );
              }

              final lastMessage = chatData['lastMessage'] ?? "";
              final lastTimestamp = (chatData['lastTimestamp'] as Timestamp?)
                  ?.toDate();

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircleAvatar(child: CircularProgressIndicator()),
                      title: Text("Loading user..."),
                    );
                  }

                  if (userSnapshot.hasError) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.error)),
                      title: const Text("Error loading user"),
                      subtitle: Text("ID: $otherUserId"),
                    );
                  }

                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_off),
                      ),
                      title: const Text("User data not available"),
                      subtitle: Text("ID: $otherUserId"),
                    );
                  }

                  final userDoc = userSnapshot.data!;

                  if (!userDoc.exists) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_off),
                      ),
                      title: const Text("User not found"),
                      subtitle: Text("ID: $otherUserId"),
                    );
                  }

                  final userData = userDoc.data();

                  if (userData == null) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.error)),
                      title: const Text("No user data available"),
                      subtitle: Text("ID: $otherUserId"),
                    );
                  }

                  final userDataMap = userData as Map<String, dynamic>;
                  final userName =
                      userDataMap['name']?.toString() ?? "Unknown User";

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : "?",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(userName),
                    subtitle: Text(
                      lastMessage.isNotEmpty ? lastMessage : "No messages yet",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: lastTimestamp != null
                        ? Text(
                            "${lastTimestamp.hour}:${lastTimestamp.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            userId: otherUserId!,
                            userName: userName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
