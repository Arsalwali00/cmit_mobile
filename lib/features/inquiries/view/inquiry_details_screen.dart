// lib/features/inquiries/view/inquiry_details_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'requested_documents.dart';
import 'add_visits.dart';
import 'visit_findings_screen.dart';
import 'edit_finding_screen.dart';
import 'finalized_finding_screen.dart';
import 'package:cmit/features/home/model/assign_to_me_model.dart';

class InquiryDetailsScreen extends StatefulWidget {
  final AssignToMeModel inquiry;

  const InquiryDetailsScreen({
    super.key,
    required this.inquiry,
  });

  @override
  State<InquiryDetailsScreen> createState() => _InquiryDetailsScreenState();
}

class _InquiryDetailsScreenState extends State<InquiryDetailsScreen> {
  late List<dynamic> documents = [];
  late List<dynamic> allVisits = [];

  // Track expansion state
  bool _detailsExpanded = false;
  bool _visitsExpanded = false;
  bool _documentsExpanded = false;
  Map<int, bool> _visitExpansionState = {};
  bool _isUploadingDocument = false;

  AssignToMeModel get i => widget.inquiry;

  @override
  void initState() {
    super.initState();
    allVisits = i.visits;
    documents = i.requiredDocuments;
    // Initialize all visits as collapsed
    for (int i = 0; i < allVisits.length; i++) {
      _visitExpansionState[i] = false;
    }
  }

  void _addDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestedDocumentsScreen(
          inquiryId: i.id,
          onAddDocument: (doc) {
            setState(() => documents.add(doc));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _uploadDocument(int documentIndex) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() => _isUploadingDocument = true);

        // TODO: Implement actual upload logic here
        // Example:
        // final file = result.files.first;
        // await DocumentUploadService.upload(
        //   inquiryId: i.id,
        //   documentId: documents[documentIndex]['id'],
        //   file: file,
        // );

        // Simulate upload delay
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          // Update document status
          documents[documentIndex]['is_uploaded'] = true;
          documents[documentIndex]['file_path'] = result.files.first.name;
          _isUploadingDocument = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document uploaded successfully'),
              backgroundColor: Color(0xFF014323),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploadingDocument = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _viewDocument(int documentIndex) {
    final doc = documents[documentIndex];
    // TODO: Implement document viewing logic
    // This could open a PDF viewer or download the file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${doc['document_type'] ?? doc.toString()}'),
        backgroundColor: Color(0xFF014323),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addVisit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVisitsScreen(
          inquiryId: i.id,
          onVisitAdded: () {
            setState(() {
              allVisits = i.visits;
              // Re-initialize expansion state for new visits
              for (int i = 0; i < allVisits.length; i++) {
                _visitExpansionState[i] ??= false;
              }
            });
          },
        ),
      ),
    );
  }

  void _navigateToFindings(Map<String, dynamic> visit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VisitFindingsScreen(
          visit: visit,
          inquiryId: i.id.toString(),
        ),
      ),
    ).then((_) {
      setState(() {
        allVisits = i.visits;
      });
    });
  }

  void _editFinding(Map<String, dynamic> visit, Map<String, dynamic> finding, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditFindingScreen(
          visit: visit,
          finding: finding,
          findingIndex: index,
          inquiryId: i.id.toString(),
          onSave: () {
            setState(() {
              allVisits = i.visits;
            });
          },
        ),
      ),
    );
  }

  void _navigateToFinalizeFinding(Map<String, dynamic> visit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinalizedFindingScreen(
          visit: visit,
          inquiryId: i.id.toString(),
        ),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          allVisits = i.visits;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isChairperson = i.isChairperson;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A1A)),
        title: const Text(
          'Inquiry Details',
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
        actions: [
          if (isChairperson)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF014323).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFF014323)),
                  const SizedBox(width: 4),
                  const Text(
                    'Chairperson',
                    style: TextStyle(
                      color: Color(0xFF014323),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildCollapsibleSection(
              title: 'Details',
              icon: Icons.info_outline,
              isExpanded: _detailsExpanded,
              onToggle: () => setState(() => _detailsExpanded = !_detailsExpanded),
              child: _buildDetailsContent(),
            ),
            _buildCollapsibleSection(
              title: 'Field Visits',
              icon: Icons.location_on,
              count: allVisits.length,
              isExpanded: _visitsExpanded,
              onToggle: () => setState(() => _visitsExpanded = !_visitsExpanded),
              onAdd: _addVisit,
              child: _buildVisitsContent(),
            ),
            _buildCollapsibleSection(
              title: 'Documents',
              icon: Icons.description_outlined,
              count: documents.length,
              isExpanded: _documentsExpanded,
              onToggle: () => setState(() => _documentsExpanded = !_documentsExpanded),
              onAdd: _addDocument,
              child: _buildDocumentsContent(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            i.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge(i.statusText, i.statusColor),
              _badge(i.priorityText, i.priorityColor),
              _badge(i.inquiryType, const Color(0xFF014323)),
            ],
          ),
          if (i.timeFrame.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  i.timeFrame,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            i.formattedDate,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    int? count,
    required bool isExpanded,
    required VoidCallback onToggle,
    VoidCallback? onAdd,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: const Color(0xFF014323)),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (count != null && count > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF014323),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (onAdd != null)
                    IconButton(
                      icon: const Icon(Icons.add, size: 20, color: Color(0xFF014323)),
                      onPressed: onAdd,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            child,
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Initiated By', i.initiator),
          _infoRow('Department', i.department),
          _infoRow('Type', i.inquiryType),
          _infoRow('Assigned To', i.assignedTo),
          const SizedBox(height: 16),
          _textSection('Description', i.description),
          const SizedBox(height: 16),
          _textSection('Terms of Reference', i.tors),
        ],
      ),
    );
  }

  Widget _buildVisitsContent() {
    if (allVisits.isEmpty) {
      return _emptyState('No field visits recorded');
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: allVisits.asMap().entries.map((entry) {
          final int visitNumber = entry.key + 1;
          final visit = entry.value as Map<String, dynamic>;
          return _visitCard(visit, visitNumber);
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentsContent() {
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
    // Extract document details
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
          color: isUploaded ? const Color(0xFF014323).withOpacity(0.3) : const Color(0xFFE0E0E0),
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
            // Document icon
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

            // Document name
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

            // Action button
            if (_isUploadingDocument)
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
                onPressed: () => _viewDocument(index),
                icon: const Icon(Icons.visibility, size: 20),
                color: const Color(0xFF014323),
                tooltip: 'View Document',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _uploadDocument(index),
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

  Widget _visitCard(Map<String, dynamic> visit, int visitNumber) {
    final findingsList = (visit['findings'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final String dateStr = (visit['visit_date'] ?? '').toString();
    final String formattedDate = _formatVisitDate(dateStr);
    final bool isExpanded = _visitExpansionState[visitNumber - 1] ?? false;

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
          // Visit Header with Number
          InkWell(
            onTap: () {
              setState(() {
                _visitExpansionState[visitNumber - 1] = !isExpanded;
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
                      'Visit $visitNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today, size: 13, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const Spacer(),
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
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[700]),
                      const SizedBox(width: 6),
                      Text(
                        (visit['visit_time'] ?? '').toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _visitInfo('Officer', (visit['officer'] ?? '').toString()),
                  const SizedBox(height: 6),
                  _visitInfo('Driver', (visit['driver'] ?? '').toString()),
                  const SizedBox(height: 6),
                  _visitInfo('Vehicle', (visit['vehicle'] ?? '').toString()),
                ],
              ),
            ),
            if (findingsList.isNotEmpty) ...[
              Divider(height: 1, color: Colors.grey[300]),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Findings (${findingsList.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToFinalizeFinding(visit),
                          icon: const Icon(Icons.check_circle, size: 16),
                          label: const Text('Finalize'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF014323),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...findingsList.asMap().entries.map((entry) {
                      final int index = entry.key + 1;
                      final Map<String, dynamic> finding = entry.value;
                      return _findingItem(
                        user: (finding['user'] ?? 'Unknown').toString(),
                        findingsText: (finding['findings'] ?? '').toString(),
                        number: index,
                        onEdit: () => _editFinding(visit, finding, index),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
            Divider(height: 1, color: Colors.grey[300]),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToFindings(visit),
                  icon: const Icon(Icons.assignment, size: 18),
                  label: const Text('Findings/Proceedings/Recommendations'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF014323),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _visitInfo(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
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

  Widget _findingItem({
    required String user,
    required String findingsText,
    required int number,
    required VoidCallback onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF014323),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 16, color: Color(0xFF014323)),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Edit Finding',
              ),
            ],
          ),
          if (findingsText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              findingsText,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ],
      ),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
      ),
    );
  }

  Widget _textSection(String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          text.isEmpty ? 'No $title provided' : text,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
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