import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Search extends StatefulWidget {
  final TextEditingController searchController;
  String query;
  Search({super.key, required this.query, required this.searchController});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              hintText: "Search...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                widget.query = value;
              });
            },
          ),
        ),
        widget.query.isEmpty
            ? const Text("Start typing to search...")
            : Text(
                "Result: ${widget.query}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }
}
