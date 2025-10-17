import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cmit/core/inquiry_utils.dart';

/// Screen to display detailed information about an inquiry.
class InquiryDetailsScreen extends StatelessWidget {
  final String ref;
  final String title;
  final String dept;
  final String assignedTo;
  final String date;
  final String status;
  final String description;
  final String tors;
  final String priority;
  final String inquiryType;
  final String initiator;
  final List<String> teamMembers;
  final List<dynamic> recommendations;
  final List<dynamic> visits;

  const InquiryDetailsScreen({
    super.key,
    required this.ref,
    required this.title,
    required this.dept,
    required this.assignedTo,
    required this.date,
    required this.status,
    required this.description,
    required this.tors,
    required this.priority,
    required this.inquiryType,
    required this.initiator,
    required this.teamMembers,
    required this.recommendations,
    required this.visits,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDetails = InquiryUtils.formatInquiryDetails(
      status: status,
      priority: priority,
      date: date,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Inquiry Details",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(formattedDetails),
            const SizedBox(height: 8),
            _buildDetailsCard(formattedDetails),
            const SizedBox(height: 12),
            _buildTeamMembersCard(),
            const SizedBox(height: 12),
            _buildRecommendationsCard(),
            const SizedBox(height: 12),
            _buildVisitsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Builds the header with title, status, and priority.
  Widget _buildHeader(Map<String, dynamic> formattedDetails) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusBadge(
                formattedDetails['statusText'] as String,
                _getStatusColor(status),
              ),
              const SizedBox(width: 12),
              _buildPriorityBadge(
                formattedDetails['priorityText'] as String,
                _getPriorityColor(priority),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the main details card.
  Widget _buildDetailsCard(Map<String, dynamic> formattedDetails) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today, 'Date', formattedDetails['formattedDate'] as String),
          _buildDivider(),
          _buildInfoRow(Icons.person_outline, 'Authority', initiator),
          _buildDivider(),
          _buildInfoRow(Icons.business, 'Department', dept),
          _buildDivider(),
          _buildInfoRow(Icons.category_outlined, 'Type', inquiryType),
          _buildDivider(),
          _buildInfoRow(Icons.assignment_ind_outlined, 'Assigned To', assignedTo),

          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 20),

          // Description Section
          Row(
            children: [
              Icon(Icons.description_outlined, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 10),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Html(
            data: description,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(15),
                lineHeight: const LineHeight(1.6),
                color: Colors.black87,
              ),
            },
          ),

          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 20),

          // Terms of Reference Section
          Row(
            children: [
              Icon(Icons.article_outlined, size: 20, color: Colors.blue[700]),
              const SizedBox(width: 10),
              const Text(
                'Terms of Reference',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Html(
            data: tors,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(15),
                lineHeight: const LineHeight(1.6),
                color: Colors.black87,
              ),
            },
          ),
        ],
      ),
    );
  }

  /// Builds the team members card.
  Widget _buildTeamMembersCard() {
    return _buildSectionCard(
      title: 'Team Members',
      icon: Icons.group_outlined,
      child: teamMembers.isEmpty
          ? _buildEmptyState('No team members assigned')
          : Wrap(
        spacing: 8,
        runSpacing: 8,
        children: teamMembers.map((member) => _buildChip(member)).toList(),
      ),
    );
  }

  /// Builds the recommendations card.
  Widget _buildRecommendationsCard() {
    return _buildSectionCard(
      title: 'Recommendations',
      icon: Icons.lightbulb_outline,
      child: recommendations.isEmpty
          ? _buildEmptyState('No recommendations available')
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recommendations.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds the visits card.
  Widget _buildVisitsCard() {
    return _buildSectionCard(
      title: 'Visits',
      icon: Icons.location_on_outlined,
      child: visits.isEmpty
          ? _buildEmptyState('No visits recorded')
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: visits.asMap().entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds a reusable section card.
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: Colors.blue[700]),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Builds an info row with icon, label, and value.
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a status badge.
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// Builds a priority badge.
  Widget _buildPriorityBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a chip for team members.
  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue[900],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Builds an empty state widget.
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  /// Builds a divider.
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
    );
  }

  /// Gets color based on status.
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'closed':
        return Colors.green;
      case 'in progress':
      case 'ongoing':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Gets color based on priority.
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}