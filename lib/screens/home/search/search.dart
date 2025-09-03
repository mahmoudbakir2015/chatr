import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  final String token;
  const Search({super.key, required this.token});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    log(widget.token);
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
                searchQuery = value.trim();
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
                  return user['uid'] == widget.token
                      ? Center(child: Text("No users found"))
                      : ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(user['name'] ?? "Unknown"),
                          subtitle: Text(user['email'] ?? ""),
                          trailing: ElevatedButton.icon(
                            onPressed: () {},
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
