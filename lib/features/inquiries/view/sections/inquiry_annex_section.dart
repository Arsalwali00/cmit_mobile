// lib/features/inquiries/view/sections/inquiry_annex_section.dart
import 'package:flutter/material.dart';
import '../add_annex.dart';

class InquiryAnnexSection extends StatefulWidget {
  final int inquiryId;
  final List<dynamic> annexes;
  final Function(Map<String, dynamic>) onNavigateToAnnexDetails;
  final Function(Map<String, dynamic>, int) onEditAnnex;
  final VoidCallback onAnnexAdded;

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

  @override
  void didUpdateWidget(InquiryAnnexSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update expansion state if annexes list changed
    if (widget.annexes.length != oldWidget.annexes.length) {
      _annexExpansionState.clear();
      for (int i = 0; i < widget.annexes.length; i++) {
        _annexExpansionState[i] = false;
      }
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
              onPressed: _navigateToAddAnnex,
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
    final String sortOrder = (annex['sort_order'] ?? '0').toString();
    final List<dynamic> files = (annex['annex_files'] ?? []) as List<dynamic>;
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
                color: const Color(0xFFE8F5E9),
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
                      color: const Color(0xFF014323),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF424242),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (files.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${files.length} file${files.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF014323),
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
                  // Files Section
                  if (files.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Text(
                      'Attached Files',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...files.map((file) => _fileItem(file as Map<String, dynamic>)),
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'No files attached',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onNavigateToAnnexDetails(annex),
                          icon: const Icon(Icons.visibility, size: 16),
                          label: const Text('View Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF014323),
                            side: const BorderSide(color: Color(0xFF014323)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: Color(0xFF014323)),
                        onPressed: () => widget.onEditAnnex(annex, annexNumber),
                        tooltip: 'Edit Annex',
                        style: IconButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF014323)),
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

  Widget _fileItem(Map<String, dynamic> file) {
    final String link = (file['link'] ?? '').toString();
    final String fileType = (file['file_type'] ?? '').toString();
    final int fileId = int.tryParse((file['annex_file_id'] ?? file['id']).toString()) ?? 0;

    // Determine file icon based on type
    IconData fileIcon;
    Color iconColor;

    if (fileType.contains('image') || link.toLowerCase().endsWith('.jpg') ||
        link.toLowerCase().endsWith('.jpeg') || link.toLowerCase().endsWith('.png')) {
      fileIcon = Icons.image;
      iconColor = Colors.blue;
    } else if (fileType.contains('pdf') || link.toLowerCase().endsWith('.pdf')) {
      fileIcon = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else {
      fileIcon = Icons.insert_drive_file;
      iconColor = Colors.grey;
    }

    // Extract filename from link
    String filename = link.split('/').last;
    if (filename.length > 30) {
      filename = '${filename.substring(0, 27)}...';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(fileIcon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'File ID: $fileId',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 18),
            onPressed: () {
              // TODO: Implement file download
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Download: $filename')),
              );
            },
            tooltip: 'Download',
            color: const Color(0xFF014323),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.folder_open,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}