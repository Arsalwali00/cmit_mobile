// lib/features/inquiries/view/requested_documents.dart
import 'package:flutter/material.dart';

class RequestedDocumentsScreen extends StatefulWidget {
  final int inquiryId; // For future API submission
  final Function(Map<String, String>) onAddDocument;

  const RequestedDocumentsScreen({
    super.key,
    required this.inquiryId,
    required this.onAddDocument,
  });

  @override
  State<RequestedDocumentsScreen> createState() => _RequestedDocumentsScreenState();
}

class _RequestedDocumentsScreenState extends State<RequestedDocumentsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDocumentType;
  final _notesController = TextEditingController();

  // Real-world document types (customize as needed)
  final List<String> documentTypes = [
    'Invoice',
    'Receipt',
    'Quotation',
    'Contract Agreement',
    'Certificate of Incorporation',
    'Business License',
    'Permit',
    'Audit Report',
    'Bank Statement',
    'Payment Voucher',
    'Delivery Note',
    'LPO / Purchase Order',
    'Tax Compliance Certificate',
    'CR12 (Company Search)',
    'ID / Passport Copy',
    'Letter of Award',
    'Completion Certificate',
    'Other',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final docData = {
        'document_type': _selectedDocumentType!,
        'notes': _notesController.text.trim().isEmpty ? 'No additional notes' : _notesController.text.trim(),
        'inquiry_id': widget.inquiryId.toString(),
        'requested_at': DateTime.now().toIso8601String(),
      };

      widget.onAddDocument(docData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Document',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.description_outlined, color: Colors.orange.shade700, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Request Supporting Document',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Specify the document required to proceed with the inquiry.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  // Document Type Dropdown
                  const Text(
                    'Document Type',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedDocumentType,
                    hint: const Text('Choose document type'),
                    validator: (value) => value == null ? 'Please select a document type' : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    items: documentTypes
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedDocumentType = value),
                  ),
                  const SizedBox(height: 20),

                  // Additional Notes (Optional)
                  const Text(
                    'Additional Instructions (Optional)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'e.g. Provide certified copies from the last 3 years...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.send, size: 20),
                          label: const Text('Request Document'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}