// lib/features/offline/view/offline_visit_findings_screen.dart - WITH OFFLINE SUPPORT
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:cmit/core/finding_inquiry_service.dart';
import 'package:cmit/features/offline/services/offline_service.dart';
import 'package:cmit/features/offline/widgets/offline_indicator.dart';

class OfflineVisitFindingsScreen extends StatefulWidget {
  final Map<String, dynamic> visit;
  final String inquiryId;

  const OfflineVisitFindingsScreen({
    super.key,
    required this.visit,
    required this.inquiryId,
  });

  @override
  State<OfflineVisitFindingsScreen> createState() => _OfflineVisitFindingsScreenState();
}

class _OfflineVisitFindingsScreenState extends State<OfflineVisitFindingsScreen> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final hasInternet = await OfflineService.hasInternet();
    if (mounted) {
      setState(() => _isOnline = hasInternet);
    }
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

    // Check connectivity again
    await _checkConnectivity();

    if (_isOnline) {
      await _submitOnline(content);
    } else {
      await _submitOffline(content);
    }
  }

  Future<void> _submitOnline(String content) async {
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
          backgroundColor: const Color(0xFF014323),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit findings'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitOffline(String content) async {
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

    final success = await OfflineService.saveFindingOffline(
      inquiryId: int.parse(widget.inquiryId),
      visitId: visitId.toString(),
      findings: content,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Findings saved offline. Will sync when online.'),
          backgroundColor: Color(0xFF014323),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save findings offline'),
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
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A1A)),
        title: const Text(
          'Findings / Proceedings / Recommendations',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
            fontSize: 16,
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
      body: SafeArea(
        child: Column(
          children: [
            // Offline Indicator
            const OfflineIndicator(),

            // Offline Mode Notice
            if (!_isOnline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF014323).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF014323),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Offline mode: Findings will be saved and synced later',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF014323).withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildVisitInfoHeader(formattedDate, visitTime),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.description, size: 20, color: Color(0xFF014323)),
                                const SizedBox(width: 8),
                                const Text(
                                  'Finding Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Toolbar
                          Container(
                            color: const Color(0xFFF8F9FA),
                            child: quill.QuillToolbar.simple(
                              configurations: quill.QuillSimpleToolbarConfigurations(
                                controller: _controller,
                                sharedConfigurations: const quill.QuillSharedConfigurations(),
                                showAlignmentButtons: true,
                                showBoldButton: true,
                                showItalicButton: true,
                                showUnderLineButton: true,
                                showListBullets: true,
                                showListNumbers: true,
                                showUndo: true,
                                showRedo: true,
                                showClearFormat: true,
                                showHeaderStyle: true,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          // Editor
                          quill.QuillEditor.basic(
                            configurations: quill.QuillEditorConfigurations(
                              controller: _controller,
                              placeholder: 'Enter findings, proceedings, and recommendations...',
                              padding: const EdgeInsets.all(16),
                              autoFocus: false,
                              expands: false,
                              scrollable: true,
                              minHeight: 300,
                              sharedConfigurations: const quill.QuillSharedConfigurations(
                                locale: Locale('en'),
                              ),
                            ),
                            focusNode: _focusNode,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitInfoHeader(String date, String time) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Color(0xFF014323),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 13, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
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
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitFindings,
          icon: _isSubmitting
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Icon(_isOnline ? Icons.send : Icons.save, size: 18),
          label: Text(
            _isSubmitting
                ? 'Submitting...'
                : _isOnline
                ? 'Submit Findings'
                : 'Save Offline',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF014323),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}