import 'package:flutter/material.dart';
import 'package:cmit/features/home/view/new_inquiry.dart';

class HomeTopSection extends StatelessWidget {
  const HomeTopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅ Stats Row
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _buildStatCard("15", "Inquiries", Colors.green[100]!)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("05", "In Progress", Colors.orange[100]!)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("15", "Closed", Colors.grey[300]!)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          /// ✅ New Inquiry Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddInquiryScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.green[900]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.green),
              label: const Text(
                "New Inquiry",
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),

          /// ✅ Recent Inquiries
          const Text(
            "Recent Inquiries",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          /// ✅ Inquiry Cards
          _buildInquiryCard(
            ref: "REF-00123",
            title: "Financial Audit of MIT Department",
            dept: "Finance",
            date: "July 01 2025",
            status: "Open",
            color: Colors.green[100]!,
          ),
          _buildInquiryCard(
            ref: "REF-00124",
            title: "IT Infrastructure Upgrade",
            dept: "IT",
            date: "July 03 2025",
            status: "In Progress",
            color: Colors.orange[100]!,
          ),
          _buildInquiryCard(
            ref: "REF-00125",
            title: "Library System Update",
            dept: "Library",
            date: "July 05 2025",
            status: "Closed",
            color: Colors.grey[300]!,
          ),
        ],
      ),
    );
  }

  /// ✅ Stat Card
  Widget _buildStatCard(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  /// ✅ Inquiry Card
  Widget _buildInquiryCard({
    required String ref,
    required String title,
    required String dept,
    required String date,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ref,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "$dept : Created on $date",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}