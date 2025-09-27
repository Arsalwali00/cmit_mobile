import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // body background color
      appBar: AppBar(
        title: const Text(
          "Activities",
          style: TextStyle(
            color: Colors.black, // ensure title is visible
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white, // appbar background
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false, // no back button
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
          color: Colors.black, // adjusted for white background
        ),
      ),
    );
  }

  Widget buildActivity(String time, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey, // softer look
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black, // make text visible on white
              ),
            ),
          ),
        ],
      ),
    );
  }
}
