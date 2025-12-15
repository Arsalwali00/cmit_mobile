// lib/features/offline/view/offline_inquiry_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cmit/features/home/model/assign_to_me_model.dart';
import 'package:cmit/features/offline/services/offline_service.dart';
import 'package:cmit/features/offline/view/offline_details_screen.dart';
import 'package:cmit/features/offline/view/offline_visit_findings_screen.dart';

// Import section widgets (reuse from main inquiry details)
import 'package:cmit/features/inquiries/view/sections/inquiry_header_section.dart';
import 'package:cmit/features/inquiries/view/sections/inquiry_details_section.dart';

class OfflineInquiryDetailsScreen extends StatefulWidget {
  final AssignToMeModel inquiry;

  const OfflineInquiryDetailsScreen({
    super.key,
    required this.inquiry,
  });

  @override
  State<OfflineInquiryDetailsScreen> createState() => _OfflineInquiryDetailsScreenState();
}

class _OfflineInquiryDetailsScreenState extends State<OfflineInquiryDetailsScreen> {
  late List<dynamic> allVisits = [];
  bool _isOnline = true;

  // Track expansion state
  bool _detailsExpanded = false;
  bool _visitsExpanded = false;
  Map<int, bool> _visitExpansionState = {};

  AssignToMeModel get i => widget.inquiry;

  @override
  void initState() {
    super.initState();
    allVisits = i.visits;
    _checkConnectivity();

    // Initialize expansion state for all visits
    for (int idx = 0; idx < allVisits.length; idx++) {
      _visitExpansionState[idx] = false;
    }
  }

  Future<void> _checkConnectivity() async {
    final hasInternet = await OfflineService.hasInternet();
    if (mounted) {
      setState(() => _isOnline = hasInternet);
    }
  }

  void _navigateToOfflineSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OfflineDetailsScreen(),
      ),
    ).then((_) {
      _checkConnectivity();
    });
  }

  void _showOfflineMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF014323),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: _navigateToOfflineSettings,
        ),
      ),
    );
  }

  void _navigateToOfflineVisitFindings(Map<String, dynamic> visit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OfflineVisitFindingsScreen(
          visit: visit,
          inquiryId: i.id.toString(),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A1A)),
        title: const Text(
          'Inquiry Details (Offline)',
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
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF014323),
              size: 22,
            ),
            onPressed: _navigateToOfflineSettings,
            tooltip: 'Offline Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline Banner
          if (!_isOnline)
            InkWell(
              onTap: _navigateToOfflineSettings,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFFE8F5E9),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 18,
                      color: Color(0xFF014323),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Offline Mode',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF014323),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Viewing cached data - Read only',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFF014323).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Color(0xFF014323),
                    ),
                  ],
                ),
              ),
            ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Header Section (Read-only)
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

                  // Field Visits Section (Same as online version)
                  _buildCollapsibleSection(
                    title: 'Field Visits',
                    icon: Icons.location_on,
                    count: allVisits.length,
                    isExpanded: _visitsExpanded,
                    onToggle: () => setState(() => _visitsExpanded = !_visitsExpanded),
                    child: _buildOfflineVisitsSection(),
                  ),

                  // Offline Info Card
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF014323).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF014323),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Limited Access',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF014323),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You can view inquiry details offline, but editing is disabled. Connect to internet to make changes.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF014323).withOpacity(0.9),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineVisitsSection() {
    if (allVisits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No field visits recorded',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...allVisits.asMap().entries.map((entry) {
            final int visitNumber = entry.key + 1;
            final visit = entry.value as Map<String, dynamic>;
            return _visitCard(visit, visitNumber);
          }).toList(),
        ],
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
                        // Read-only badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Read-only',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
                  onPressed: () => _navigateToOfflineVisitFindings(visit),
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
              // Read-only indicator instead of edit button
              Icon(
                Icons.lock_outline,
                size: 16,
                color: Colors.grey[400],
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

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    int? count,
    required bool isExpanded,
    required VoidCallback onToggle,
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