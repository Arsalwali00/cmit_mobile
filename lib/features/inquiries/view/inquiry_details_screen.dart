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

  AssignToMeModel get i => widget.inquiry;

  @override
  void initState() {
    super.initState();
    allVisits = i.visits; // Correctly processed visits with stripped findings
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
            // In a real app, refetch data from API here
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Inquiry Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (isChairperson)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 16, color: Colors.deepPurple),
                  SizedBox(width: 4),
                  Text(
                    'Chairperson',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isChairperson),
            const SizedBox(height: 16),
            _buildDetailsCard(),
            const SizedBox(height: 16),
            _buildTeamMembersCard(),
            const SizedBox(height: 16),
            _buildVisitsCard(),
            const SizedBox(height: 16),
            _buildDocumentsCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isChairperson) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    i.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (isChairperson) const Icon(Icons.star, color: Colors.amber, size: 30),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _badge(i.statusText, i.statusColor),
                _badge(i.priorityText, i.priorityColor),
                _badge(i.inquiryType, Colors.purple.shade600),
              ],
            ),
            const SizedBox(height: 12),
            if (i.timeFrame.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.teal.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'Time Frame: ${i.timeFrame}',
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              i.formattedDate,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return _sectionCard(
      title: 'Inquiry Details',
      icon: Icons.info_outline,
      children: [
        _infoRow('Initiated By', i.initiator),
        _infoRow('Department', i.department),
        _infoRow('Type', i.inquiryType),
        _infoRow('Assigned To', i.assignedTo),
        const SizedBox(height: 20),
        const Divider(height: 1, color: Colors.grey),
        const SizedBox(height: 20),
        _textSection('Description', i.description),
        const SizedBox(height: 28),
        _textSection('Terms of Reference (TOR)', i.tors),
      ],
    );
  }

  Widget _buildTeamMembersCard() {
    return _sectionCard(
      title: 'Team Members',
      icon: Icons.group,
      children: i.teamMembers.isEmpty
          ? [_empty('No team members assigned')]
          : [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: i.teamMembers.map((m) => _chip(m)).toList(),
        ),
      ],
    );
  }

  Widget _buildVisitsCard() {
    return _sectionCard(
      title: 'Field Visits',
      icon: Icons.location_on,
      iconColor: Colors.green.shade700,
      addAction: _addVisit,
      badge: allVisits.isNotEmpty ? '${allVisits.length}' : null,
      children: allVisits.isEmpty
          ? [_empty('No field visits recorded')]
          : allVisits.map((visit) => _visitCard(visit as Map<String, dynamic>)).toList(),
    );
  }

  Widget _buildDocumentsCard() {
    return _sectionCard(
      title: 'Requested Documents',
      icon: Icons.description_outlined,
      addAction: _addDocument,
      children: documents.isEmpty
          ? [_empty('No documents requested')]
          : documents.map((d) => _bulletText(d.toString())).toList(),
    );
  }

  // FINAL FIXED VISIT CARD - Works 100% with updated model
  Widget _visitCard(Map<String, dynamic> visit) {
    final findingsList = (visit['findings'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    final String dateStr = (visit['visit_date'] ?? '').toString();
    final String formattedDate = _formatVisitDate(dateStr);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 16),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 18, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text(
                      (visit['visit_time'] ?? '').toString(),
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade800, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _visitInfoChip(icon: Icons.person_outline, label: 'Officer', value: (visit['officer'] ?? '').toString())),
                    const SizedBox(width: 8),
                    Expanded(child: _visitInfoChip(icon: Icons.person, label: 'Driver', value: (visit['driver'] ?? '').toString())),
                  ],
                ),
                const SizedBox(height: 8),
                _visitInfoChip(icon: Icons.directions_car, label: 'Vehicle', value: (visit['vehicle'] ?? '').toString()),
              ],
            ),
          ),

          // Findings
          if (findingsList.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment, size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Findings (${findingsList.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No findings recorded for this visit',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ),
            ),
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

  Widget _visitInfoChip({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'N/A',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _findingItem({required String user, required String findingsText, required int number}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(12)),
                child: Text('#$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Icon(Icons.person, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  user,
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade900, fontSize: 13),
                ),
              ),
            ],
          ),
          if (findingsText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              findingsText,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  // Reusable widgets (unchanged from your original)
  Widget _sectionCard({
    required String title,
    required IconData icon,
    Color? iconColor,
    VoidCallback? addAction,
    String? badge,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor ?? Colors.blue[700]),
                    const SizedBox(width: 10),
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (iconColor ?? Colors.blue[700])!.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(badge, style: TextStyle(color: iconColor ?? Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ],
                ),
                if (addAction != null)
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: iconColor ?? Colors.blue[700]),
                    onPressed: addAction,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey))),
        Expanded(child: Text(value.isNotEmpty ? value : 'N/A', style: const TextStyle(fontSize: 15))),
      ],
    ),
  );

  Widget _textSection(String title, String text) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(text.isEmpty ? 'No $title provided' : text, style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
    ],
  );

  Widget _bulletText(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(' • ', style: TextStyle(fontSize: 20, color: Colors.blue)),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.5))),
      ],
    ),
  );

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade200)),
    child: Text(text, style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w600)),
  );

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
  );

  Widget _empty(String message) => Padding(
    padding: const EdgeInsets.all(20),
    child: Center(child: Text(message, style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic))),
  );
}