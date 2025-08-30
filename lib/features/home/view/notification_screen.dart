import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  final List<Map<String, String>> notifications = const [
    {
      "title": "New Comment",
      "message": "A new Comment has been added to the inquiry.",
      "time": "1m ago",
      "avatar": "assets/images/user1.jpg"
    },
    {
      "title": "Inquiry Updated",
      "message": "The Status of the inquiry 'Environment Audit Was Changed'",
      "time": "1m ago",
      "avatar": "assets/images/user2.jpg"
    },
    {
      "title": "New Comment",
      "message": "A new Comment has been added to the inquiry.",
      "time": "1m ago",
      "avatar": "assets/images/user3.jpg"
    },
    {
      "title": "Inquiry Updated",
      "message": "The Status of the inquiry 'Environment Audit Was Changed'",
      "time": "1m ago",
      "avatar": "assets/images/user4.jpg"
    },
    {
      "title": "New Comment",
      "message": "A new Comment has been added to the inquiry.",
      "time": "1m ago",
      "avatar": "assets/images/user5.jpg"
    },
    {
      "title": "Inquiry Updated",
      "message": "The Status of the inquiry 'Environment Audit Was Changed'",
      "time": "1m ago",
      "avatar": "assets/images/user6.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notification",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(item["avatar"]!),
              radius: 24,
            ),
            title: Text(
              item["title"]!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              item["message"]!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              item["time"]!,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
