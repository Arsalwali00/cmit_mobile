// lib/features/inquiries/view/inquiry_details_screen.dart
import 'package:flutter/material.dart';
import 'package:cmit/features/home/model/assign_to_me_model.dart';

// Import section widgets
import 'sections/inquiry_header_section.dart';
import 'sections/inquiry_details_section.dart';
import 'sections/inquiry_visits_section.dart';
import 'sections/inquiry_documents_section.dart';

// Import navigation screens
import 'add_visits.dart';
import 'visit_findings_screen.dart';
import 'edit_finding_screen.dart';
import 'finalized_finding_screen.dart';

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

  AssignToMeModel get i => widget.inquiry;

  @override
  void initState() {
    super.initState();
    allVisits = i.visits;
    documents = i.requiredDocuments;
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: Color(0xFF014323)),
                  SizedBox(width: 4),
                  Text(
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
            // Header Section
            InquiryHeaderSection(inquiry: i),

            const SizedBox(height: 8),

            // Details Section
            _buildCollapsibleSection(
              title: 'Details',
              icon: Icons.info_outline,
              isExpanded: _detailsExpanded,
              onToggle: () => setState(() => _detailsExpanded = !_detailsExpanded),
              child: InquiryDetailsSection(inquiry: i),
            ),

            // Field Visits Section
            _buildCollapsibleSection(
              title: 'Field Visits',
              icon: Icons.location_on,
              count: allVisits.length,
              isExpanded: _visitsExpanded,
              onToggle: () => setState(() => _visitsExpanded = !_visitsExpanded),
              child: InquiryVisitsSection(
                visits: allVisits,
                onNavigateToFindings: _navigateToFindings,
                onEditFinding: _editFinding,
                onNavigateToFinalizeFinding: _navigateToFinalizeFinding,
                onAddVisit: _addVisit,
              ),
            ),

            // Documents Section
            _buildCollapsibleSection(
              title: 'Documents',
              icon: Icons.description_outlined,
              count: documents.length,
              isExpanded: _documentsExpanded,
              onToggle: () => setState(() => _documentsExpanded = !_documentsExpanded),
              child: InquiryDocumentsSection(
                initialDocuments: documents,
                inquiryId: i.id,
                onDocumentsChanged: (updatedDocs) {
                  setState(() {
                    documents = updatedDocs;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
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
}