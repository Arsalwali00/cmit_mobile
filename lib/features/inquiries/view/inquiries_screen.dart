import 'package:flutter/material.dart';
import 'package:cmit/core/assign_to_me.dart';
import 'package:cmit/core/inquiry_utils.dart';
import 'package:cmit/features/inquiries/view/inquiry_card.dart';
import 'package:cmit/features/home/model/assign_to_me_model.dart';
import 'package:cmit/features/inquiries/view/inquiry_details_screen.dart';

class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  _InquiriesScreenState createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  List<AssignToMeModel> inquiries = [];
  List<AssignToMeModel> filteredInquiries = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInquiries();
    _searchController.addListener(_filterInquiries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetch inquiries from API
  Future<void> _fetchInquiries() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final response = await AssignToMe.getAssignedInquiries();

    setState(() {
      isLoading = false;
      if (response['success'] == true) {
        inquiries = response['inquiries'] as List<AssignToMeModel>;
        filteredInquiries = inquiries;
      } else {
        errorMessage = response['message'] ?? 'Failed to load inquiries';
      }
    });
  }

  /// Filter inquiries based on search input
  void _filterInquiries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredInquiries = inquiries.where((inquiry) {
        return inquiry.title.toLowerCase().contains(query) ||
            inquiry.inquiryRequestId.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Inquiries",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                hintText: "Search",
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 📋 Inquiry List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : filteredInquiries.isEmpty
                  ? const Center(child: Text("No inquiries found"))
                  : ListView.builder(
                itemCount: filteredInquiries.length,
                itemBuilder: (context, index) {
                  final inquiry = filteredInquiries[index];
                  // Use helper function for formatting
                  final formattedDetails = InquiryUtils.formatInquiryDetails(
                    status: inquiry.status,
                    priority: inquiry.priority,
                    date: inquiry.createdAt,
                  );
                  return InquiryCard(
                    title: inquiry.title,
                    department: inquiry.department.name,
                    date: formattedDetails['formattedDate'],
                    status: formattedDetails['statusText'],
                    statusBackgroundColor: formattedDetails['statusBackgroundColor'],
                    statusTextColor: formattedDetails['statusTextColor'],
                    priority: formattedDetails['priorityText'],
                    inquiryType: inquiry.inquiryType.name,
                    initiator: inquiry.initiator.name,
                    assignedTo: inquiry.assignedTo.name,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InquiryDetailsScreen(
                            ref: inquiry.inquiryRequestId,
                            title: inquiry.title,
                            dept: inquiry.department.name,
                            assignedTo: inquiry.assignedTo.name,
                            date: inquiry.createdAt,
                            status: inquiry.status,
                            description: inquiry.description,
                            tors: inquiry.tors,
                            priority: inquiry.priority,
                            inquiryType: inquiry.inquiryType.name,
                            initiator: inquiry.initiator.name,
                            teamMembers: inquiry.teamMembers.map((member) => member.user.name).toList(),
                            recommendations: inquiry.recommendations ?? [],
                            visits: inquiry.visits ?? [],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}