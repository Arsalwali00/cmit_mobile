// lib/features/inquiries/view/inquiry_card.dart
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Chairperson badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      i.title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (i.isChairperson)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.deepPurple),
                          SizedBox(width: 4),
                          Text(
                            "Chairperson",
                            style: TextStyle(
                              fontSize:11,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Status + Priority + Time Frame chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(i.statusText, i.statusColor),
                  _buildChip(i.priorityText, i.priorityColor),
                  if (i.timeFrame.isNotEmpty)
                    _buildChip("Time: ${i.timeFrame}", Colors.teal.shade600),
                ],
              ),
              const SizedBox(height: 12),

              // Details rows
              _buildInfoRow(Icons.business, i.department),
              _buildInfoRow(Icons.person_outline, "Initiated by: ${i.initiator}"),
              _buildInfoRow(Icons.assignment_ind, "Assigned to: ${i.assignedTo}"),
              _buildInfoRow(Icons.category_outlined, i.inquiryType),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.access_time, "Created: ${i.formattedDate}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11.5,
        ),
      ),
    );
  }
}