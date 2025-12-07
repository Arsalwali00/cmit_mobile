// lib/features/inquiries/view/finalized_finding_screen.dart
import 'package:flutter/material.dart';

class FinalizedFindingScreen extends StatefulWidget {
  final Map<String, dynamic> visit;
  final String inquiryId;

  const FinalizedFindingScreen({
    super.key,
    required this.visit,
    required this.inquiryId,
  });

  @override
  State<FinalizedFindingScreen> createState() => _FinalizedFindingScreenState();
}

class _FinalizedFindingScreenState extends State<FinalizedFindingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _conclusionController = TextEditingController();
  final TextEditingController _recommendationsController = TextEditingController();
  final TextEditingController _actionTakenController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _conclusionController.dispose();
    _recommendationsController.dispose();
    _actionTakenController.dispose();
    super.dispose();
  }

  Future<void> _submitFinalization() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement API call to finalize the finding
      // Example:
      // final response = await apiService.finalizeFinding(
      //   inquiryId: widget.inquiryId,
      //   visitId: widget.visit['id'],
      //   conclusion: _conclusionController.text,
      //   recommendations: _recommendationsController.text,
      //   actionTaken: _actionTakenController.text,
      // );

      await Future.delayed(const Duration(seconds: 1)); // Simulating API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Finding finalized successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final findingsList = (widget.visit['findings'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Finalize Finding',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildVisitInfo(),
            const SizedBox(height: 8),
            _buildFindingsSummary(findingsList),
            const SizedBox(height: 8),
            _buildFinalizationForm(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildVisitInfo() {
    final String dateStr = (widget.visit['visit_date'] ?? '').toString();
    final String formattedDate = _formatVisitDate(dateStr);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                (widget.visit['visit_time'] ?? '').toString(),
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Officer', (widget.visit['officer'] ?? '').toString()),
          const SizedBox(height: 6),
          _infoRow('Driver', (widget.visit['driver'] ?? '').toString()),
          const SizedBox(height: 6),
          _infoRow('Vehicle', (widget.visit['vehicle'] ?? '').toString()),
        ],
      ),
    );
  }

  Widget _buildFindingsSummary(List<Map<String, dynamic>> findingsList) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Findings Summary (${findingsList.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (findingsList.isEmpty)
            Text(
              'No findings recorded',
              style: TextStyle(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            )
          else
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
    );
  }

  Widget _buildFinalizationForm() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_document, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
                const Text(
                  'Finalization Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _conclusionController,
              label: 'Conclusion',
              hint: 'Enter the conclusion based on findings',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a conclusion';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _recommendationsController,
              label: 'Recommendations',
              hint: 'Enter recommendations',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter recommendations';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _actionTakenController,
              label: 'Action Taken / Next Steps',
              hint: 'Enter action taken or next steps',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter action taken or next steps';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[700]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitFinalization,
                icon: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.check_circle, size: 20),
                label: Text(
                  _isLoading ? 'Finalizing...' : 'Finalize Finding',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _findingItem({
    required String user,
    required String findingsText,
    required int number,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  user,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (findingsText.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              findingsText,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
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

  String _formatVisitDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr.split(' ').first);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
}