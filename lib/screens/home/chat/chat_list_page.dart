import 'package:flutter/material.dart';

class ChatPageList extends StatefulWidget {
  const ChatPageList({super.key});

  @override
  State<ChatPageList> createState() => _ChatPageListState();
}

class _ChatPageListState extends State<ChatPageList> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Chat Page",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
