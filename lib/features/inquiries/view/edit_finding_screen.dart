// lib/features/inquiries/view/edit_finding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

class EditFindingScreen extends StatefulWidget {
  final Map<String, dynamic> visit;
  final Map<String, dynamic> finding;
  final int findingIndex;
  final String inquiryId;
  final VoidCallback onSave;

  const EditFindingScreen({
    super.key,
    required this.visit,
    required this.finding,
    required this.findingIndex,
    required this.inquiryId,
    required this.onSave,
  });

  @override
  State<EditFindingScreen> createState() => _EditFindingScreenState();
}

class _EditFindingScreenState extends State<EditFindingScreen> {
  late QuillController _controller;
  bool _isSaving = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    final String findingText = widget.finding['findings']?.toString() ?? '';

    // Try to parse as Delta JSON first, otherwise treat as plain text
    Document document;
    try {
      final deltaJson = jsonDecode(findingText);
      document = Document.fromJson(deltaJson);
    } catch (e) {
      // If not JSON, treat as plain text
      document = Document()..insert(0, findingText);
    }

    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveFinding() async {
    final plainText = _controller.document.toPlainText().trim();

    if (plainText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter finding details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Get the Delta JSON for storage
      final deltaJson = jsonEncode(_controller.document.toDelta().toJson());

      // TODO: Implement actual API call to update finding
      // Example:
      // await apiService.updateFinding(
      //   inquiryId: widget.inquiryId,
      //   visitId: widget.visit['id'].toString(),
      //   findingId: widget.finding['id'].toString(),
      //   findings: deltaJson, // Store as Delta JSON
      // );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update the finding locally
      widget.finding['findings'] = deltaJson;

      if (mounted) {
        widget.onSave();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Finding updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update finding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String user = widget.finding['user']?.toString() ?? 'Unknown';
    final String visitDate = widget.visit['visit_date']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Edit Finding',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInfoCard(user, visitDate),
                  const SizedBox(height: 8),
                  _buildQuillEditor(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String user, String visitDate) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${widget.findingIndex}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    if (visitDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(visitDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuillEditor() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.description, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Finding Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Quill Toolbar
          Container(
            color: Colors.grey[50],
            child: QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(
                controller: _controller,
                sharedConfigurations: const QuillSharedConfigurations(),
                showAlignmentButtons: true,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showListBullets: true,
                showListNumbers: true,
                showListCheck: false,
                showCodeBlock: false,
                showQuote: false,
                showIndent: true,
                showLink: false,
                showUndo: true,
                showRedo: true,
                showDirection: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                showInlineCode: false,
                showFontFamily: false,
                showFontSize: false,
                showClearFormat: true,
                showHeaderStyle: true,
              ),
            ),
          ),
          const Divider(height: 1),
          // Quill Editor
          Container(
            constraints: const BoxConstraints(minHeight: 300),
            padding: const EdgeInsets.all(16),
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                controller: _controller,
                placeholder: 'Enter finding details...',
                padding: EdgeInsets.zero,
                autoFocus: false,
                expands: false,
                scrollable: true,
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('en'),
                ),
              ),
              focusNode: _focusNode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveFinding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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
}