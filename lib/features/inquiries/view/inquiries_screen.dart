import 'package:flutter/material.dart';
import 'package:cmit/core/assign_to_me.dart';
import 'package:cmit/features/inquiries/view/inquiry_card.dart';
import 'package:cmit/features/inquiries/view/inquiry_details_screen.dart';
import 'package:cmit/features/home/model/assign_to_me_model.dart';

class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  List<AssignToMeModel> _inquiries = [];
  List<AssignToMeModel> _filtered = [];
  bool _isLoading = true;
  String _error = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInquiries();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInquiries() async {
    setState(() => _isLoading = true);
    try {
      final result = await AssignToMe.getAssignedInquiries();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (result['success'] == true) {
          _inquiries = result['inquiries'] as List<AssignToMeModel>;
          _filtered = List.from(_inquiries);
        } else {
          _error = result['message'] ?? 'Failed to load inquiries';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Please check your connection';
      });
    }
  }

  void _filter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = query.isEmpty
          ? List.from(_inquiries)
          : _inquiries.where((i) {
        return i.title.toLowerCase().contains(query) ||
            i.department.toLowerCase().contains(query) ||
            i.initiator.toLowerCase().contains(query) ||
            i.assignedTo.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Inquiries', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search inquiries...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadInquiries, child: const Text('Retry')),
                ],
              ),
            )
                : _filtered.isEmpty
                ? const Center(child: Text('No inquiries found'))
                : RefreshIndicator(
              onRefresh: _loadInquiries,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final inquiry = _filtered[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InquiryCard(
                      inquiry: inquiry,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => InquiryDetailsScreen(inquiry: inquiry)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}