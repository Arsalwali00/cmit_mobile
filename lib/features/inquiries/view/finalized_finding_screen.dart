// lib/features/inquiries/view/finalized_finding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';

class FinalizedFindingScreen extends StatefulWidget {
  final Map<String, dynamic> visit;
  final String inquiryId;

  const FinalizedFindingScreen({
    super.key,
    required this.visit,
    required this.inquiryId,
  });

  @override
  State<FinalizedFindingScreen> createState() => _FinalizedFindingScreenState();
}

class _FinalizedFindingScreenState extends State<FinalizedFindingScreen> {
  final _formKey = GlobalKey<FormState>();
  late quill.QuillController _quillController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeQuillController();
  }

  void _initializeQuillController() {
    final findingsList = (widget.visit['findings'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    // Build combined findings text
    String combinedFindings = '';
    for (int i = 0; i < findingsList.length; i++) {
      final finding = findingsList[i];
      final user = (finding['user'] ?? 'Unknown').toString();
      final findingsText = (finding['findings'] ?? '').toString();

      if (i > 0) combinedFindings += '\n\n';
      combinedFindings += 'Finding #${i + 1} - $user\n$findingsText';
    }

    // Initialize QuillController with combined findings
    try {
      // Try to parse as JSON first (in case it's already Quill delta format)
      final delta = quill.Document.fromJson(jsonDecode(combinedFindings));
      _quillController = quill.QuillController(
        document: delta,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // If not JSON, treat as plain text
      _quillController = quill.QuillController.basic();
      if (combinedFindings.isNotEmpty) {
        _quillController.document.insert(0, combinedFindings);
      }
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _submitFinalization() async {
    setState(() => _isLoading = true);

    try {
      // Get the content from Quill editor
      final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());
      final plainText = _quillController.document.toPlainText();

      // TODO: Implement API call to finalize the finding
      // Example:
      // final response = await apiService.finalizeFinding(
      //   inquiryId: widget.inquiryId,
      //   visitId: widget.visit['id'],
      //   findingsContent: deltaJson, // Store as JSON for rich text
      //   findingsPlainText: plainText, // Store plain text for searching
      // );

      await Future.delayed(const Duration(seconds: 1)); // Simulating API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Finding finalized successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Finalize Finding',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          _buildVisitInfo(),
          const SizedBox(height: 8),
          Expanded(
            child: _buildQuillEditor(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildVisitInfo() {
    final String dateStr = (widget.visit['visit_date'] ?? '').toString();
    final String formattedDate = _formatVisitDate(dateStr);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                (widget.visit['visit_time'] ?? '').toString(),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Officer', (widget.visit['officer'] ?? '').toString()),
          const SizedBox(height: 6),
          _infoRow('Driver', (widget.visit['driver'] ?? '').toString()),
          const SizedBox(height: 6),
          _infoRow('Vehicle', (widget.visit['vehicle'] ?? '').toString()),
        ],
      ),
    );
  }

  Widget _buildQuillEditor() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Toolbar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: quill.QuillToolbar.simple(
              configurations: quill.QuillSimpleToolbarConfigurations(
                controller: _quillController,
                sharedConfigurations: const quill.QuillSharedConfigurations(),
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
          // Editor
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: quill.QuillEditor.basic(
                configurations: quill.QuillEditorConfigurations(
                  controller: _quillController,
                  sharedConfigurations: const quill.QuillSharedConfigurations(
                    locale: Locale('en'),
                  ),
                  placeholder: 'Edit findings here...',
                  padding: EdgeInsets.zero,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitFinalization,
                icon: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.check_circle, size: 20),
                label: Text(
                  _isLoading ? 'Finalizing...' : 'Finalize Finding',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'N/A',
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  String _formatVisitDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr.split(' ').first);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}