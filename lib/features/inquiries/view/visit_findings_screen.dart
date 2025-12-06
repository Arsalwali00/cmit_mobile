// lib/features/inquiries/view/visit_findings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:cmit/core/finding_inquiry_service.dart'; // Adjust path if needed

class VisitFindingsScreen extends StatefulWidget {
  final Map<String, dynamic> visit;
  final String inquiryId;

  const VisitFindingsScreen({
    super.key,
    required this.visit,
    required this.inquiryId,
  });

  @override
  State<VisitFindingsScreen> createState() => _VisitFindingsScreenState();
}

class _VisitFindingsScreenState extends State<VisitFindingsScreen> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final existingContent =
        widget.visit['findings_proceedings_recommendations']?.toString() ?? '';

    final doc = quill.Document();
    if (existingContent.isNotEmpty) {
      doc.insert(0, existingContent);
    }

    _controller = quill.QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitFindings() async {
    final content = _controller.document.toPlainText().trim();

    if (content.isEmpty || content == '\n') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter findings before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final visitId = widget.visit['id'];
    if (visitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visit ID not found!'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final result = await FindingInquiryService.storeFinding(
      findings: content,
      visitId: int.parse(visitId.toString()),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Findings submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit findings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatVisitDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr.split(' ').first);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String dateStr = (widget.visit['visit_date'] ?? '').toString();
    final String formattedDate = _formatVisitDate(dateStr);
    final String visitTime = (widget.visit['visit_time'] ?? '').toString();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Finding / Proceedings / Recommendations',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            Text(
              'Visit $formattedDate',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          _isSubmitting
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : TextButton.icon(
            onPressed: _isSubmitting ? null : _submitFindings,
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Submit'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildVisitInfoHeader(formattedDate, visitTime),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Toolbar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        iconTheme: IconThemeData(color: Colors.grey[700]),
                      ),
                      child: quill.QuillToolbar.simple(
                        configurations: quill.QuillSimpleToolbarConfigurations(
                          controller: _controller,
                          showAlignmentButtons: false,
                          showBackgroundColorButton: false,
                          showCodeBlock: false,
                          showColorButton: false,
                          showFontFamily: false,
                          showFontSize: false,
                          showHeaderStyle: true,
                          showIndent: true,
                          showListBullets: true,
                          showListNumbers: true,
                          showQuote: true,
                          showBoldButton: true,
                          showItalicButton: true,
                          showUnderLineButton: true,
                          showStrikeThrough: true,
                          multiRowsDisplay: false,
                        ),
                      ),
                    ),
                  ),
                  // Editor
                  Expanded(
                    child: quill.QuillEditor.basic(
                      configurations: quill.QuillEditorConfigurations(
                        controller: _controller,
                        autoFocus: true,
                        expands: false,
                        padding: const EdgeInsets.all(16),
                        placeholder: 'Enter findings, proceedings, and recommendations here...',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVisitInfoHeader(String date, String time) {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.calendar_today, size: 16, color: Colors.blue[700]),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(time, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildInfoRow('Officer', (widget.visit['officer'] ?? 'N/A').toString()),
                const SizedBox(height: 8),
                _buildInfoRow('Driver', (widget.visit['driver'] ?? 'N/A').toString()),
                const SizedBox(height: 8),
                _buildInfoRow('Vehicle', (widget.visit['vehicle'] ?? 'N/A').toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text('$label:', style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}