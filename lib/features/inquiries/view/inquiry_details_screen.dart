// lib/features/inquiries/view/inquiry_details_screen.dart
import 'package:flutter/material.dart';
import 'requested_documents.dart';
import 'add_visits.dart';
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
  bool _detailsExpanded = true;
  bool _teamExpanded = true;
  bool _visitsExpanded = true;
  bool _documentsExpanded = true;

  AssignToMeModel get i => widget.inquiry;

  @override
  void initState() {
    super.initState();
    allVisits = i.visits;
    documents = i.requiredDocuments;
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

  void _addVisit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVisitsScreen(
          inquiryId: i.id,
          onAddVisit: (visitData) {
            setState(() {
              allVisits = i.visits;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isChairperson = i.isChairperson;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Inquiry Details',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        actions: [
          if (isChairperson)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: Colors.deepPurple.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Chairperson',
                    style: TextStyle(
                      color: Colors.deepPurple.shade700,
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
              title: 'Team Members',
              icon: Icons.group,
              count: i.teamMembers.length,
              isExpanded: _teamExpanded,
              onToggle: () => setState(() => _teamExpanded = !_teamExpanded),
              child: _buildTeamContent(),
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
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge(i.statusText, i.statusColor),
              _badge(i.priorityText, i.priorityColor),
              _badge(i.inquiryType, Colors.purple.shade700),
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
                  Icon(icon, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (count != null && count > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (onAdd != null)
                    IconButton(
                      icon: Icon(Icons.add, size: 20, color: Colors.grey[700]),
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

  Widget _buildTeamContent() {
    if (i.teamMembers.isEmpty) {
      return _emptyState('No team members assigned');
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: i.teamMembers.map((m) => _chip(m)).toList(),
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
        children: allVisits
            .map((visit) => _visitCard(visit as Map<String, dynamic>))
            .toList(),
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
        children: documents
            .map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              Expanded(
                child: Text(
                  d.toString(),
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }

  Widget _visitCard(Map<String, dynamic> visit) {
    final findingsList = (visit['findings'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final String dateStr = (visit['visit_date'] ?? '').toString();
    final String formattedDate = _formatVisitDate(dateStr);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[700]),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
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
                  Text(
                    'Findings (${findingsList.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...findingsList.asMap().entries.map((entry) {
                    final int index = entry.key + 1;
                    final Map<String, dynamic> finding = entry.value;
                    return _findingItem(
                      user: (finding['user'] ?? 'Unknown').toString(),
                      findingsText: (finding['findings'] ?? '').toString(),
                      number: index,
                    );
                  }).toList(),
                ],
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
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
            color: Colors.black87,
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

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
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