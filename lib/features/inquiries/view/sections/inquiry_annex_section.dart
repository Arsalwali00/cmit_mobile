// lib/features/inquiries/view/sections/inquiry_annex_section.dart
import 'package:flutter/material.dart';
import '../add_annex.dart'; // Import the AddAnnexScreen

class InquiryAnnexSection extends StatefulWidget {
  final int inquiryId; // Added inquiryId parameter
  final List<dynamic> annexes;
  final Function(Map<String, dynamic>) onNavigateToAnnexDetails;
  final Function(Map<String, dynamic>, int) onEditAnnex;
  final VoidCallback onAnnexAdded; // Changed from onAddAnnex to onAnnexAdded for refresh

  const InquiryAnnexSection({
    super.key,
    required this.inquiryId,
    required this.annexes,
    required this.onNavigateToAnnexDetails,
    required this.onEditAnnex,
    required this.onAnnexAdded,
  });

  @override
  State<InquiryAnnexSection> createState() => _InquiryAnnexSectionState();
}

class _InquiryAnnexSectionState extends State<InquiryAnnexSection> {
  Map<int, bool> _annexExpansionState = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.annexes.length; i++) {
      _annexExpansionState[i] = false;
    }
  }

  void _navigateToAddAnnex() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAnnexScreen(
          inquiryId: widget.inquiryId,
          onAnnexAdded: widget.onAnnexAdded,
        ),
      ),
    );

    // If annex was added successfully, refresh the list
    if (result == true) {
      widget.onAnnexAdded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (widget.annexes.isEmpty)
            _emptyState('No annexes added yet')
          else
            ...widget.annexes.asMap().entries.map((entry) {
              final int annexNumber = entry.key + 1;
              final annex = entry.value as Map<String, dynamic>;
              return _annexCard(annex, annexNumber);
            }).toList(),

          const SizedBox(height: 12),

          // Add Annex Button
          Center(
            child: OutlinedButton.icon(
              onPressed: _navigateToAddAnnex, // Updated to use navigation method
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Annex'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF014323),
                side: const BorderSide(color: Color(0xFF014323)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _annexCard(Map<String, dynamic> annex, int annexNumber) {
    final String title = (annex['title'] ?? 'Untitled').toString();
    final String description = (annex['description'] ?? '').toString();
    final String dateStr = (annex['created_date'] ?? '').toString();
    final String formattedDate = _formatDate(dateStr);
    final bool isExpanded = _annexExpansionState[annexNumber - 1] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _annexExpansionState[annexNumber - 1] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isExpanded ? Radius.zero : const Radius.circular(12),
                  bottomRight: isExpanded ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF57C00),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Annex $annexNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF424242),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFFF57C00),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[700]),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onNavigateToAnnexDetails(annex),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFF57C00),
                            side: const BorderSide(color: Color(0xFFF57C00)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: Color(0xFFF57C00)),
                        onPressed: () => widget.onEditAnnex(annex, annexNumber),
                        tooltip: 'Edit Annex',
                        style: IconButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF57C00)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr.split(' ').first);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}