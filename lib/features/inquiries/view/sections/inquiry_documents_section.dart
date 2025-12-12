// lib/features/inquiries/view/sections/inquiry_documents_section.dart
import 'package:flutter/material.dart';

class InquiryDocumentsSection extends StatelessWidget {
  final List<dynamic> documents;
  final Function(int) onUploadDocument;
  final Function(int) onViewDocument;
  final bool isUploadingDocument;

  const InquiryDocumentsSection({
    super.key,
    required this.documents,
    required this.onUploadDocument,
    required this.onViewDocument,
    this.isUploadingDocument = false,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return _emptyState('No documents requested');
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: documents.asMap().entries.map((entry) {
          final int index = entry.key;
          final doc = entry.value;
          return _documentItem(doc, index);
        }).toList(),
      ),
    );
  }

  Widget _documentItem(dynamic doc, int index) {
    String documentName;
    bool isUploaded = false;

    if (doc is Map<String, dynamic>) {
      documentName = doc['document_type']?.toString() ??
          doc['attachment_type']?.toString() ??
          'Document ${index + 1}';
      isUploaded = doc['is_uploaded'] == true ||
          doc['file_path'] != null && doc['file_path'].toString().isNotEmpty;
    } else {
      documentName = doc.toString();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUploaded
              ? const Color(0xFF014323).withOpacity(0.3)
              : const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle : Icons.description_outlined,
                color: isUploaded ? const Color(0xFF014323) : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploaded ? 'Uploaded' : 'Not uploaded',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUploaded
                          ? const Color(0xFF014323)
                          : Colors.grey[600],
                      fontWeight: isUploaded ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (isUploadingDocument)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF014323)),
                ),
              )
            else if (isUploaded)
              IconButton(
                onPressed: () => onViewDocument(index),
                icon: const Icon(Icons.visibility, size: 20),
                color: const Color(0xFF014323),
                tooltip: 'View Document',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              ElevatedButton.icon(
                onPressed: () => onUploadDocument(index),
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF014323),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}