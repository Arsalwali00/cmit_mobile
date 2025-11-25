// lib/features/inquiries/view/inquiry_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'add_recommendations.dart';
import 'add_visits.dart';
import 'requested_documents.dart';
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
  late List<dynamic> recommendations;
  late List<dynamic> visits;
  late List<dynamic> documents = [];

  @override
  void initState() {
    super.initState();
    recommendations = List.from(widget.inquiry.recommendations);
    visits = List.from(widget.inquiry.visits);
  }

  // Clean access to inquiry
  AssignToMeModel get i => widget.inquiry;

  void _addRecommendation() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddRecommendationScreen(
        inquiryId: i.id,
        onAddRecommendation: (text) {
          setState(() => recommendations.add(text));
          Navigator.pop(context);
        },
      ),
    ),
  );

  void _addVisit() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddVisitsScreen(
        inquiryId: i.id,
        onAddVisit: (visit) {
          setState(() => visits.add(visit));
          Navigator.pop(context);
        },
      ),
    ),
  );

  void _addDocument() => Navigator.push(
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

  @override
  Widget build(BuildContext context) {
    final isChairperson = i.isChairperson;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text('Inquiry Details', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  Text('Chairperson', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
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
            _buildRecommendationsCard(),
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

  // HEADER — Clean, no Ref ID
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
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
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
                    style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w600, fontSize: 14),
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
        _htmlSection('Description', i.description),
        const SizedBox(height: 28),
        _htmlSection('Terms of Reference (TOR)', i.tors),
      ],
    );
  }

  Widget _buildTeamMembersCard() {
    return _sectionCard(
      title: 'Team Members',
      icon: Icons.group,
      children: i.teamMembers.isEmpty
          ? [_empty('No team members assigned')]
          : [Wrap(spacing: 10, runSpacing: 10, children: i.teamMembers.map((m) => _chip(m)).toList())],
    );
  }

  Widget _buildRecommendationsCard() {
    return _sectionCard(
      title: 'Recommendations',
      icon: Icons.lightbulb_outline,
      addAction: _addRecommendation,
      children: recommendations.isEmpty
          ? [_empty('No recommendations added yet')]
          : recommendations.map((r) => _bulletText(r.toString())).toList(),
    );
  }

  Widget _buildVisitsCard() {
    return _sectionCard(
      title: 'Field Visits',
      icon: Icons.location_on_outlined,
      addAction: _addVisit,
      children: visits.isEmpty
          ? [_empty('No visits recorded')]
          : visits.map((v) {
        final data = v is Map<String, dynamic> ? v : {};
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Text('Field Visit', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              if (data.isNotEmpty) ...[
                _visitRow('Date', data['date']),
                _visitRow('Time', data['time']),
                _visitRow('Driver', data['driver']),
                _visitRow('Vehicle', data['vehicle']),
                _visitRow('Findings', data['findings'] ?? 'No findings recorded'),
              ],
            ],
          ),
        );
      }).toList(),
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

  // Reusable Components
  Widget _sectionCard({
    required String title,
    required IconData icon,
    VoidCallback? addAction,
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
                    Icon(icon, color: Colors.blue[700]),
                    const SizedBox(width: 10),
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (addAction != null)
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: Colors.blue[700]),
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
        SizedBox(
          width: 120,
          child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
      ],
    ),
  );

  Widget _visitRow(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        children: [
          TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: value ?? '-'),
        ],
      ),
    ),
  );

  Widget _htmlSection(String title, String html) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Html(
        data: html.isEmpty ? '<p>No $title provided</p>' : html,
        style: {
          "body": Style(fontSize: FontSize(15), lineHeight: LineHeight(1.6), color: Colors.black87),
          "p": Style(margin: Margins.symmetric(vertical: 4)),
        },
      ),
    ],
  );

  Widget _bulletText(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 20, color: Colors.blue)),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, height: 1.5))),
      ],
    ),
  );

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.blue.shade200),
    ),
    child: Text(text, style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w600)),
  );

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
  );

  Widget _empty(String message) => Padding(
    padding: const EdgeInsets.all(20),
    child: Center(
      child: Text(message, style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
    ),
  );
}