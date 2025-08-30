import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activities"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          buildSectionTitle("Today"),
          buildActivity("10:24 am", "You added a comment"),
          buildActivity("10:24 am", "The Status was Changed"),
          buildActivity("10:24 am", "You Added a Comment"),

          const SizedBox(height: 16),
          buildSectionTitle("Yesterday"),
          buildActivity("10:24 am", "You added a comment"),
          buildActivity("10:24 am", "The Status was Changed"),
          buildActivity("10:24 am", "You Added a Comment"),

          const SizedBox(height: 16),
          buildSectionTitle("July 1, 2026"),
          buildActivity("10:24 am", "Inquiry Reassigned"),

          const SizedBox(height: 16),
          buildSectionTitle("June 1, 2026"),
          buildActivity("10:24 am", "Inquiry Reassigned"),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildActivity(String time, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
