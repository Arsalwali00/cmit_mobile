// lib/features/inquiries/view/add_attachment_annex.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddAttachmentAnnexScreen extends StatefulWidget {
  final int annexId;
  final String annexTitle;
  final VoidCallback onAttachmentAdded;

  const AddAttachmentAnnexScreen({
    super.key,
    required this.annexId,
    required this.annexTitle,
    required this.onAttachmentAdded,
  });

  @override
  State<AddAttachmentAnnexScreen> createState() => _AddAttachmentAnnexScreenState();
}

class _AddAttachmentAnnexScreenState extends State<AddAttachmentAnnexScreen> {
  final List<Map<String, dynamic>> _selectedFiles = [];
  bool _isUploading = false;

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      setState(() {
        for (var file in result.files) {
          if (file.path != null) {
            final extension = (file.extension ?? 'pdf').toLowerCase();
            final mimeType = _getMimeType(extension);

            _selectedFiles.add({
              'path': file.path!,
              'name': file.name,
              'size': file.size,
              'extension': extension,
              'mime_type': mimeType,
            });
          }
        }
      });
    } catch (e) {
      _showSnackBar('Error picking files: $e', isError: true);
    }
  }

  String _getMimeType(String extension) {
    return {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
    }[extension] ?? 'application/octet-stream';
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _uploadAttachments() async {
    if (_selectedFiles.isEmpty) {
      _showSnackBar('Please select at least one file', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      // TODO: Implement API call to upload attachments
      // This is a placeholder - replace with your actual API call

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Example API call structure:
      /*
      final List<String> base64Files = [];

      for (var fileData in _selectedFiles) {
        final file = File(fileData['path']);
        final bytes = await file.readAsBytes();
        final base64String = 'data:${fileData['mime_type']};base64,${base64Encode(bytes)}';
        base64Files.add(base64String);
      }

      final response = await http.post(
        Uri.parse('https://cmit.sata.pk/api/annex/${widget.annexId}/attachments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: jsonEncode({
          'annex_id': widget.annexId,
          'files': base64Files,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          // Success
        }
      }
      */

      if (mounted) {
        _showSnackBar(
          '${_selectedFiles.length} ${_selectedFiles.length == 1 ? 'file' : 'files'} uploaded successfully',
          isError: false,
        );

        widget.onAttachmentAdded();

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        _showSnackBar('Upload failed: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A1A)),
        title: const Text(
          'Add Attachments',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E5E5),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Annex Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF014323),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Annex',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.annexTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Add files to this annex',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // File Picker Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickFiles,
              icon: const Icon(Icons.attach_file, size: 20),
              label: const Text('Select Files'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF014323),
                side: const BorderSide(color: Color(0xFF014323)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Selected Files List
          Expanded(
            child: _selectedFiles.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No files selected',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap "Select Files" to choose files',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.description,
                          size: 20,
                          color: Color(0xFF014323),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_selectedFiles.length} ${_selectedFiles.length == 1 ? 'file' : 'files'} selected',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _selectedFiles.length,
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildFileItem(_selectedFiles[index], index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Upload Button
          if (_selectedFiles.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadAttachments,
                icon: _isUploading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : const Icon(Icons.cloud_upload, size: 20),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Upload Files',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF014323),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileItem(Map<String, dynamic> fileData, int index) {
    final String name = fileData['name'];
    final int size = fileData['size'];
    final String extension = fileData['extension'];

    IconData icon;
    Color iconColor;

    if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
      icon = Icons.image;
      iconColor = Colors.blue[700]!;
    } else if (extension == 'pdf') {
      icon = Icons.picture_as_pdf;
      iconColor = Colors.red[700]!;
    } else {
      icon = Icons.insert_drive_file;
      iconColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatFileSize(size)} • ${extension.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isUploading ? null : () => _removeFile(index),
            icon: const Icon(Icons.close),
            color: Colors.red[700],
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}