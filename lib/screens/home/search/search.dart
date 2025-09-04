import 'dart:developer';
import 'package:chatr/screens/home/chat/chat_screen/chat_screen.dart';
import 'package:chatr/utils/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String searchQuery = "";
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
    log(token.toString(), name: 'search token');
  }

  @override
  Widget build(BuildContext context) {
    log(myToken.toString(), name: 'search token');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search by name...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.trim().toLowerCase();
              });
            },
          ),
        ),

        // 📋 Search Results
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: searchQuery.isEmpty
                ? const Stream.empty()
                : FirebaseFirestore.instance
                      .collection('users')
                      .where('name', isGreaterThanOrEqualTo: searchQuery)
                      .where('name', isLessThanOrEqualTo: "$searchQuery\uf8ff")
                      .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 20),
                    Text("Start typing to search for users"),
                  ],
                );
              }

              final users = snapshot.data!.docs;

              if (users.isEmpty) {
                return const Center(child: Text("No users found"));
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return user['uid'] == myToken
                      ? Center(child: Text("No users found"))
                      : ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(
                            user['name'].toString().toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(user['email'] ?? ""),
                          trailing: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    userId: user['uid'],
                                    userName: user['name'] ?? "Unknown",
                                  ),
                                ),
                              );
                            },
                            label: Icon(Icons.chat),
                            icon: Text("Chat"),
                          ),
                        );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
