import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cmit/core/inquiry_utils.dart'; // Import the helper function

class InquiryDetailsScreen extends StatelessWidget {
  final String ref;
  final String title;
  final String dept;
  final String assignedTo;
  final String date;
  final String status;
  final String description;
  final String priority;
  final String inquiryType;
  final String initiator;

  const InquiryDetailsScreen({
    super.key,
    required this.ref,
    required this.title,
    required this.dept,
    required this.assignedTo,
    required this.date,
    required this.status,
    required this.description,
    required this.priority,
    required this.inquiryType,
    required this.initiator,
  });

  @override
  Widget build(BuildContext context) {
    // Use the helper function to format status, priority, and date
    final formattedDetails = InquiryUtils.formatInquiryDetails(
      status: status,
      priority: priority,
      date: date,
    );

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
                const SizedBox(height: 8),

                // Priority
                Text(
                  formattedDetails['priorityText'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Date
                Text(
                  formattedDetails['formattedDate'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Authority (Initiator)
                _buildInfoRow("Authority", initiator),

                const Divider(height: 24),

                // Department
                _buildInfoRow("Dept", dept),

                const Divider(height: 24),

                // Type (Inquiry Type)
                _buildInfoRow("Type", inquiryType),

                const Divider(height: 24),

                // Submitted to (Assigned to)
                _buildInfoRow("Submitted to", assignedTo),

                const Divider(height: 24),

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
                        color: formattedDetails['statusBackgroundColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        formattedDetails['statusText'],
                        style: TextStyle(
                          color: formattedDetails['statusTextColor'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
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
                Html(
                  data: description,
                  style: {
                    "body": Style(
                      color: Colors.black87,
                      lineHeight: const LineHeight(1.4),
                    ),
                  },
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
          "$title:",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}