import 'package:flutter/material.dart';
import 'package:cmit/core/assign_to_me.dart';
import 'package:cmit/features/home/model/assign_to_me_model.dart';
import 'package:cmit/features/inquiries/view/inquiry_details_screen.dart'; // Import the InquiryDetailsScreen

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
                  return InquiryCard(
                    ref: inquiry.inquiryRequestId,
                    title: inquiry.title,
                    department: inquiry.department.name,
                    date: inquiry.createdAt.split('T')[0],
                    status: _mapStatus(inquiry.status),
                    onTap: () {
                      // Navigate to InquiryDetailsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InquiryDetailsScreen(
                            ref: inquiry.inquiryRequestId,
                            title: inquiry.title,
                            dept: inquiry.department.name,
                            assignedTo: inquiry.assignedTo.name,
                            date: inquiry.createdAt.split('T')[0],
                            status: _mapStatus(inquiry.status),
                            description: inquiry.description,
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

  /// Map status code to display text
  String _mapStatus(String status) {
    switch (status) {
      case '1':
        return 'Open';
      case '2':
        return 'In Progress';
      case '3':
        return 'Closed';
      default:
        return 'Unknown';
    }
  }
}

// 🔹 Reusable Inquiry Card
class InquiryCard extends StatelessWidget {
  final String ref;
  final String title;
  final String department;
  final String date;
  final String status;
  final VoidCallback? onTap; // Added onTap callback

  const InquiryCard({
    super.key,
    required this.ref,
    required this.title,
    required this.department,
    required this.date,
    required this.status,
    this.onTap, // Optional onTap parameter
  });

  Color _getStatusColor() {
    switch (status) {
      case 'Open':
        return Colors.green.shade100;
      case 'In Progress':
        return Colors.orange.shade100;
      case 'Closed':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case 'Open':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Closed':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handle tap to navigate
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ref + Status Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref,
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getTextColor(),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),

              // Department + Date
              Text(
                "$department : Created on $date",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}