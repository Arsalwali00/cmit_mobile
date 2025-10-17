import 'package:flutter/material.dart';

class InquiryDetailsScreen extends StatelessWidget {
  final String ref;
  final String title;
  final String dept;
  final String assignedTo;
  final String date;
  final String status;
  final String description;

  const InquiryDetailsScreen({
    super.key,
    required this.ref,
    required this.title,
    required this.dept,
    required this.assignedTo,
    required this.date,
    required this.status,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Inquiry Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reference ID
                Text(
                  ref,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Status
                Row(
                  children: [
                    const Text(
                      "Status",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: _getTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Department
                _buildInfoRow("Department", dept),

                const Divider(height: 24),

                // Assigned to
                _buildInfoRow("Assigned to", assignedTo),

                const Divider(height: 24),

                // Date Created
                _buildInfoRow("Date Created", date),

                const Divider(height: 24),

                // Description
                const Text(
                  "Description",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Row widget
  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Match status colors with InquiriesScreen
  Color _getStatusColor() {
    switch (status) {
      case 'Open':
        return Colors.green.shade100;
      case 'In Progress':
        return Colors.orange.shade100;
      case 'Closed':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case 'Open':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Closed':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }
}