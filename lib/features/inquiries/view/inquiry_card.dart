import 'package:flutter/material.dart';
import 'package:cmit/features/home/model/assign_to_me_model.dart';

class InquiryCard extends StatelessWidget {
  final AssignToMeModel inquiry;
  final VoidCallback? onTap;

  const InquiryCard({
    super.key,
    required this.inquiry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final i = inquiry;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Text(
                  i.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Status Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBadge(i.statusText, i.statusColor),
                    _buildBadge(i.priorityText, i.priorityColor),
                    if (i.timeFrame.isNotEmpty)
                      _buildBadge(i.timeFrame, const Color(0xFF00897B)),
                  ],
                ),
                const SizedBox(height: 16),

                // Details
                _buildDetailRow(
                  Icons.business_outlined,
                  i.department,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.person_outline,
                  i.initiator,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.assignment_ind_outlined,
                  i.assignedTo,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.category_outlined,
                  i.inquiryType,
                ),
                const SizedBox(height: 12),

                // Footer
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFF0F0F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        i.formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF757575),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF424242),
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}