import 'package:flutter/material.dart';

class InquiriesScreen extends StatelessWidget {
  const InquiriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🔹 Body background set to white
      appBar: AppBar(
        title: const Text(
          "Inquiries",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 🔹 removes back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                hintText: "Search",
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 📋 Inquiry List
            Expanded(
              child: ListView(
                children: const [
                  InquiryCard(
                    ref: "REF-00123",
                    title: "Financial Audit of MIT Department",
                    department: "Finance",
                    date: "July 01 2025",
                    status: "Open",
                  ),
                  InquiryCard(
                    ref: "REF-00124",
                    title: "Budget Planning for Q3",
                    department: "Finance",
                    date: "July 02 2025",
                    status: "Open",
                  ),
                  InquiryCard(
                    ref: "REF-00125",
                    title: "HR Compliance Review",
                    department: "HR",
                    date: "July 03 2025",
                    status: "In Progress",
                  ),
                  InquiryCard(
                    ref: "REF-00126",
                    title: "IT Security Audit",
                    department: "IT",
                    date: "July 04 2025",
                    status: "In Progress",
                  ),
                  InquiryCard(
                    ref: "REF-00127",
                    title: "Procurement Policy Review",
                    department: "Procurement",
                    date: "July 05 2025",
                    status: "Closed",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Reusable Inquiry Card
class InquiryCard extends StatelessWidget {
  final String ref;
  final String title;
  final String department;
  final String date;
  final String status;

  const InquiryCard({
    super.key,
    required this.ref,
    required this.title,
    required this.department,
    required this.date,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status) {
      case "Open":
        return Colors.green.shade100;
      case "In Progress":
        return Colors.orange.shade100;
      case "Closed":
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case "Open":
        return Colors.green;
      case "In Progress":
        return Colors.orange;
      case "Closed":
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white, // 🔹 Card background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black, width: 1), // Black border
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ref + Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ref,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getTextColor(),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),

            // Department + Date
            Text(
              "$department : Created on $date",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
