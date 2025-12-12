// lib/features/inquiries/view/sections/inquiry_documents_section.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:cmit/core/required_document_upload_service.dart';
import '../requested_documents.dart';

class InquiryDocumentsSection extends StatefulWidget {
  final List<dynamic> initialDocuments;
  final dynamic inquiryId;
  final Function(List<Map<String, dynamic>>) onDocumentsChanged;

  const InquiryDocumentsSection({
    super.key,
    required this.initialDocuments,
    required this.inquiryId,
    required this.onDocumentsChanged,
  });

  @override
  State<InquiryDocumentsSection> createState() => _InquiryDocumentsSectionState();
}

class _InquiryDocumentsSectionState extends State<InquiryDocumentsSection> {
  late List<Map<String, dynamic>> documents;
  final Set<int> _uploadingIndices = <int>{};

  @override
  void initState() {
    super.initState();
    // Fixed the broken line that caused a compile error
    documents = widget.initialDocuments
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  @override
  void didUpdateWidget(covariant InquiryDocumentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDocuments != oldWidget.initialDocuments) {
      setState(() {
        documents = widget.initialDocuments
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      });
    }
  }

  // MARK: - Upload Document
  Future<void> _uploadDocument(int index) async {
    final doc = documents[index];

    final int? requiredDocumentId = doc['id'] ?? doc['required_document_id'];
    if (requiredDocumentId == null) {
      _showSnackBar('Document ID missing', isError: true);
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty || result.files.first.path == null) {
      return; // user cancelled
    }

    setState(() => _uploadingIndices.add(index));

    try {
      final file = File(result.files.first.path!);
      final bytes = await file.readAsBytes();
      final String extension =
      (result.files.first.extension ?? 'pdf').toLowerCase();

      final String mimeType = {
        'pdf': 'application/pdf',
        'doc': 'application/msword',
        'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
      }[extension] ??
          'application/octet-stream';

      // Full data URI – exactly what your backend expects
      final String dataUri = 'data:$mimeType;base64,${base64Encode(bytes)}';

      final uploadResult = await RequiredDocumentUploadService.uploadDocument(
        requiredDocumentId: requiredDocumentId,
        base64WithDataUri: dataUri,
      );

      if (uploadResult['success'] == true && mounted) {
        setState(() {
          documents[index]
            ..['is_uploaded'] = true
            ..['file_path'] = result.files.first.name
            ..['file_base64'] = dataUri
            ..['file_size'] = bytes.length
            ..['mime_type'] = mimeType;
        });

        widget.onDocumentsChanged(documents);
        _showSnackBar('Document uploaded successfully', isError: false);
      } else {
        throw Exception(uploadResult['message'] ?? 'Upload failed');
      }
    } catch (e) {
      debugPrint('Document upload error: $e');
      if (mounted) {
        _showSnackBar('Upload failed: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingIndices.remove(index));
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF014323),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _viewDocument(int index) {
    final doc = documents[index];
    final name = doc['document_type'] ??
        doc['attachment_type'] ??
        'Document ${index + 1}';
    _showSnackBar('Opening: $name', isError: false);
    // TODO: Implement actual document viewer (PDF/image)
  }

  void _addDocument() {
    final int parsedInquiryId = widget.inquiryId is int
        ? widget.inquiryId
        : int.tryParse(widget.inquiryId.toString()) ?? 0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestedDocumentsScreen(
          inquiryId: parsedInquiryId,
          onAddDocument: (newDoc) {
            setState(() {
              documents.add(newDoc as Map<String, dynamic>);
            });
            widget.onDocumentsChanged(documents);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return _emptyState('No documents requested');
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...documents.asMap().entries.map((entry) {
            final int index = entry.key;
            final Map<String, dynamic> doc = entry.value;
            return _documentItem(doc, index);
          }).toList(),
          const SizedBox(height: 12),
          // Optional: Add button if you allow adding extra documents
          // Center(
          //   child: OutlinedButton.icon(
          //     onPressed: _addDocument,
          //     icon: const Icon(Icons.add),
          //     label: const Text('Request Additional Document'),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _documentItem(Map<String, dynamic> doc, int index) {
    final String documentName = doc['document_type']?.toString() ??
        doc['attachment_type']?.toString() ??
        'Document ${index + 1}';

    final bool isUploaded = doc['is_uploaded'] == true ||
        (doc['file_path']?.toString().isNotEmpty ?? false);

    final bool isUploading = _uploadingIndices.contains(index);

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
            // Icon
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

            // Title + Status
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploading
                        ? 'Uploading...'
                        : isUploaded
                        ? 'Uploaded'
                        : 'Not uploaded',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUploading
                          ? Colors.orange[700]
                          : isUploaded
                          ? const Color(0xFF014323)
                          : Colors.grey[600],
                      fontWeight:
                      isUploading || isUploaded ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // Action button / loader
            if (isUploading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF014323)),
                ),
              )
            else if (isUploaded)
              IconButton(
                onPressed: () => _viewDocument(index),
                icon: const Icon(Icons.visibility, size: 20),
                color: const Color(0xFF014323),
                tooltip: 'View Document',
              )
            else
              ElevatedButton.icon(
                onPressed: () => _uploadDocument(index),
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('Upload', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF014323),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}