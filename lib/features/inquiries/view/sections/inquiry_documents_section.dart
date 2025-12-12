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

  // Base URL for the API
  static const String baseUrl = 'https://cmit.sata.pk';

  @override
  void initState() {
    super.initState();
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

  // Get full URL for image/document
  String _getFullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Remove leading slash if present to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }

  // Check if document has attachments
  bool _hasAttachments(Map<String, dynamic> doc) {
    final attachments = doc['attachments'];
    if (attachments == null) return false;
    if (attachments is! List) return false;
    return attachments.isNotEmpty;
  }

  // Get attachment count
  int _getAttachmentCount(Map<String, dynamic> doc) {
    final attachments = doc['attachments'];
    if (attachments == null || attachments is! List) return 0;
    return attachments.length;
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
      return;
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
    final attachments = doc['attachments'] as List?;

    if (attachments == null || attachments.isEmpty) {
      _showSnackBar('No attachments available', isError: true);
      return;
    }

    // Show bottom sheet with all attachments
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAttachmentsSheet(doc, attachments),
    );
  }

  Widget _buildAttachmentsSheet(Map<String, dynamic> doc, List attachments) {
    final documentName = doc['attachment_type']?.toString() ?? 'Document';

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      documentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${attachments.length} ${attachments.length == 1 ? 'attachment' : 'attachments'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: attachments.length,
                  itemBuilder: (context, index) {
                    final attachment = attachments[index] as Map<String, dynamic>;
                    return _buildAttachmentItem(attachment, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem(Map<String, dynamic> attachment, int index) {
    final fileType = attachment['file_type']?.toString() ?? '';
    final link = attachment['link']?.toString() ?? '';
    final attachmentType = attachment['attachment_type']?.toString() ?? 'File';
    final fullUrl = _getFullUrl(link);

    IconData icon;
    Color iconColor;

    if (fileType.contains('image')) {
      icon = Icons.image;
      iconColor = Colors.blue[700]!;
    } else if (fileType.contains('pdf')) {
      icon = Icons.picture_as_pdf;
      iconColor = Colors.red[700]!;
    } else {
      icon = Icons.insert_drive_file;
      iconColor = Colors.grey[700]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          attachmentType,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          fileType,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: IconButton(
          onPressed: () => _openDocument(fullUrl, fileType, attachmentType),
          icon: const Icon(Icons.open_in_new),
          color: const Color(0xFF014323),
          tooltip: 'Open',
        ),
      ),
    );
  }

  void _openDocument(String url, String fileType, String title) {
    if (url.isEmpty) {
      _showSnackBar('Document URL not available', isError: true);
      return;
    }

    // If it's an image, show in fullscreen viewer
    if (fileType.contains('image')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewerScreen(
            imageUrl: url,
            title: title,
          ),
        ),
      );
    } else {
      // For PDFs and other documents, you can use url_launcher
      // Add url_launcher to pubspec.yaml: url_launcher: ^6.2.0
      _showSnackBar('Opening: $title', isError: false);
      // Uncomment when url_launcher is added:
      // launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
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
              documents.add(newDoc);
            });
            widget.onDocumentsChanged(documents);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (documents.isEmpty)
            _emptyState('No documents requested yet')
          else
            ...documents.asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, dynamic> doc = entry.value;
              return _documentItem(doc, index);
            }).toList(),

          const SizedBox(height: 12),

          // Request Document Button
          Center(
            child: OutlinedButton.icon(
              onPressed: _addDocument,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Request Document'),
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

  Widget _documentItem(Map<String, dynamic> doc, int index) {
    final String documentName = doc['document_type']?.toString() ??
        doc['attachment_type']?.toString() ??
        'Document ${index + 1}';

    final bool hasAttachments = _hasAttachments(doc);
    final int attachmentCount = _getAttachmentCount(doc);
    final bool isUploading = _uploadingIndices.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasAttachments
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
                color: hasAttachments
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                hasAttachments ? Icons.check_circle : Icons.description_outlined,
                color: hasAttachments ? const Color(0xFF014323) : Colors.grey[600],
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
                        : hasAttachments
                        ? '$attachmentCount ${attachmentCount == 1 ? 'file' : 'files'} uploaded'
                        : 'Not uploaded',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUploading
                          ? Colors.orange[700]
                          : hasAttachments
                          ? const Color(0xFF014323)
                          : Colors.grey[600],
                      fontWeight:
                      isUploading || hasAttachments ? FontWeight.w500 : FontWeight.normal,
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
            else if (hasAttachments)
              ElevatedButton.icon(
                onPressed: () => _viewDocument(index),
                icon: const Icon(Icons.visibility, size: 16),
                label: Text(
                  attachmentCount > 1 ? 'View All' : 'View',
                  style: const TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF014323),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Image Viewer Screen
class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}