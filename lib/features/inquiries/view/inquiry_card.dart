import 'package:flutter/material.dart';

/// Reusable Inquiry Card widget to display inquiry details in a structured format.
class InquiryCard extends StatelessWidget {
  // Inquiry metadata
  final String title;
  final String department;
  final String date;
  final String priority;
  final String inquiryType;

  // Personnel information
  final String initiator;
  final String assignedTo;

  // Status display properties
  final String status;
  final Color statusBackgroundColor;
  final Color statusTextColor;

  // Interaction callback
  final VoidCallback? onTap;

  // UI constants
  static const double _cardPadding = 16.0;
  static const double _spacing = 8.0;
  static const double _borderRadius = 12.0;
  static const double _statusChipHorizontalPadding = 12.0;
  static const double _statusChipVerticalPadding = 6.0;
  static const double _elevation = 2.0;

  const InquiryCard({
    super.key,
    required this.title,
    required this.department,
    required this.date,
    required this.priority,
    required this.inquiryType,
    required this.initiator,
    required this.assignedTo,
    required this.status,
    required this.statusBackgroundColor,
    required this.statusTextColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: _spacing, horizontal: 8.0),
        elevation: _elevation,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(_cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: _spacing),
                    _buildPriority(),
                    const SizedBox(height: _spacing),
                    _buildDetailsSection(),
                  ],
                ),
              ),
              // Status chip column
              _buildStatusChip(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the title widget with bold and larger font.
  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the priority widget with a distinct color for emphasis.
  Widget _buildPriority() {
    return Text(
      priority,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  /// Builds the details section with date, initiator, department, type, and assignedTo.
  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow(Icons.calendar_today, date),
        const SizedBox(height: _spacing),
        _buildDetailRow(Icons.person, 'Authority: $initiator'),
        const SizedBox(height: _spacing),
        _buildDetailRow(Icons.business, 'Dept: $department'),
        const SizedBox(height: _spacing),
        _buildDetailRow(Icons.category, 'Type: $inquiryType'),
        const SizedBox(height: _spacing),
        _buildDetailRow(Icons.assignment_ind, 'Submitted to: $assignedTo'),
      ],
    );
  }

  /// Builds a single detail row with an icon and text.
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the status chip widget aligned to the right.
  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _statusChipHorizontalPadding,
        vertical: _statusChipVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: statusBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusTextColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}