// lib/features/inquiries/view/add_attachment_annex.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import 'package:cmit/core/annex_file_service.dart';

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
  double _uploadProgress = 0.0;

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'], // Only images
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        for (var platformFile in result.files) {
          if (platformFile.path != null) {
            final extension = (platformFile.extension ?? 'jpg').toLowerCase();
            final mimeType = _getMimeType(extension);

            _selectedFiles.add({
              'path': platformFile.path!,
              'name': platformFile.name,
              'size': platformFile.size,
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
    final map = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
    };
    return map[extension] ?? 'image/jpeg';
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<String> _convertFileToDataUrl(String filePath, String mimeType) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      debugPrint('Error converting file to data URL: $e');
      rethrow;
    }
  }

  Future<void> _uploadAttachments() async {
    if (_selectedFiles.isEmpty) {
      _showSnackBar('Please select at least one image', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Convert files to data URLs
      final List<String> dataUrls = [];

      for (int i = 0; i < _selectedFiles.length; i++) {
        final fileData = _selectedFiles[i];

        // Update progress for conversion
        if (mounted) {
          setState(() {
            _uploadProgress = (i / _selectedFiles.length) * 0.3;
          });
        }

        final dataUrl = await _convertFileToDataUrl(
          fileData['path'],
          fileData['mime_type'],
        );

        dataUrls.add(dataUrl);
      }

      // Update progress
      if (mounted) {
        setState(() {
          _uploadProgress = 0.5;
        });
      }

      // Prepare API payload
      final payload = {
        'annex_id': widget.annexId,
        'files': dataUrls,
      };

      final result = await AnnexFileService.uploadAnnexImages(payload);

      // Complete progress
      if (mounted) {
        setState(() {
          _uploadProgress = 1.0;
        });
      }

      if (result['success']) {
        _showSnackBar(
          '${_selectedFiles.length} ${_selectedFiles.length == 1 ? 'image' : 'images'} uploaded successfully!',
          isError: false,
        );

        widget.onAttachmentAdded();

        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showSnackBar(result['message'] ?? 'Upload failed', isError: true);
      }
    } catch (e) {
      debugPrint('Upload exception: $e');
      _showSnackBar('Upload failed. Please try again.', isError: true);
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
        duration: const Duration(seconds: 4),
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
          'Add Images',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E5E5), height: 1),
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
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.annexTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Add images to this annex',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
              icon: const Icon(Icons.image, size: 20),
              label: const Text('Select Images'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF014323),
                side: const BorderSide(color: Color(0xFF014323)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  Icon(Icons.image_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No images selected', style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Tap "Select Images" to choose images', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
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
                        const Icon(Icons.image, size: 20, color: Color(0xFF014323)),
                        const SizedBox(width: 8),
                        Text(
                          '${_selectedFiles.length} ${_selectedFiles.length == 1 ? 'image' : 'images'} selected',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _selectedFiles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _buildFileItem(_selectedFiles[index], index),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Upload Button with Progress
          if (_selectedFiles.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadAttachments,
                    icon: _isUploading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : const Icon(Icons.cloud_upload, size: 20),
                    label: Text(
                      _isUploading ? 'Uploading... ${_uploadProgress > 0 ? '${(_uploadProgress * 100).toStringAsFixed(0)}%' : ''}' : 'Upload Images',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF014323),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (_isUploading && _uploadProgress > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF014323)),
                      ),
                    ),
                ],
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
              color: Colors.blue[700]!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image, color: Colors.blue[700], size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatFileSize(size)} • ${extension.toUpperCase()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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