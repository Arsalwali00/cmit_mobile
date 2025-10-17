import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Helper function to format inquiry details such as status, priority, and date.
class InquiryUtils {
  /// Formats inquiry details and returns a map with display values and colors.
  /// - status: The status code from the API (e.g., "1", "2", "3").
  /// - priority: The priority code from the API (e.g., "1", "2", "3").
  /// - date: The date string from the API (e.g., "2025-10-12 07:46:05" or ISO 8601).
  /// Returns a map containing formatted values and colors.
  static Map<String, dynamic> formatInquiryDetails({
    required String status,
    required String priority,
    required String date,
  }) {
    // Map status code to display text and colors
    String statusText;
    Color statusBackgroundColor;
    Color statusTextColor;

    switch (status) {
      case '1':
        statusText = 'Open';
        statusBackgroundColor = Colors.green.shade100;
        statusTextColor = Colors.green;
        break;
      case '2':
        statusText = 'In Progress';
        statusBackgroundColor = Colors.orange.shade100;
        statusTextColor = Colors.orange;
        break;
      case '3':
        statusText = 'Closed';
        statusBackgroundColor = Colors.purple.shade100;
        statusTextColor = Colors.purple;
        break;
      default:
        statusText = 'Unknown';
        statusBackgroundColor = Colors.grey.shade300;
        statusTextColor = Colors.black;
    }

    // Map priority code to display text
    String priorityText;
    switch (priority) {
      case '1':
        priorityText = 'Low';
        break;
      case '2':
        priorityText = 'Medium';
        break;
      case '3':
        priorityText = 'High';
        break;
      default:
        priorityText = 'Unknown';
    }

    // Format date to "dd MMM yyyy" (e.g., "12 Oct 2025")
    String formattedDate = '';
    try {
      // Handle both "2025-10-12 07:46:05" and ISO 8601 formats
      DateTime parsedDate = DateTime.parse(date);
      formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      // Fallback to splitting if date parsing fails
      formattedDate = date.split('T')[0].split(' ')[0];
    }

    return {
      'statusText': statusText,
      'statusBackgroundColor': statusBackgroundColor,
      'statusTextColor': statusTextColor,
      'priorityText': priorityText,
      'formattedDate': formattedDate,
    };
  }
}