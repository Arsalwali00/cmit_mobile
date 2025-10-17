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
  static const double _chipHorizontalPadding = 12.0;
  static const double _chipVerticalPadding = 6.0;
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
                    _buildDetailsSection(),
                  ],
                ),
              ),
              // Status and Priority chips column
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusChip(),
                  const SizedBox(height: _spacing),
                  _buildPriorityChip(),
                ],
              ),
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

  /// Builds the status chip widget.
  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _chipHorizontalPadding,
        vertical: _chipVerticalPadding,
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

  /// Builds the priority chip widget with dynamic colors.
  Widget _buildPriorityChip() {
    // Assign colors based on priority value
    final Map<String, Map<String, Color>> priorityColors = {
      'High': {
        'background': Colors.red[100]!,
        'text': Colors.red[900]!,
      },
      'Medium': {
        'background': Colors.yellow[100]!,
        'text': Colors.yellow[900]!,
      },
      'Low': {
        'background': Colors.blue[100]!, // Similar to "in progress" style
        'text': Colors.blue[900]!,
      },
    };

    final colors = priorityColors[priority] ??
        {
          'background': Colors.blue[100]!, // Default to blue for "in progress" style
          'text': Colors.white,
        };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _chipHorizontalPadding,
        vertical: _chipVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: colors['text'],
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}