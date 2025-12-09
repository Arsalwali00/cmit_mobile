import 'package:flutter/material.dart';
import 'package:cmit/core/document_type_service.dart';
import 'package:cmit/features/inquiries/model/document_type_model.dart';

class RequestedDocumentsScreen extends StatefulWidget {
  final int inquiryId;
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

  DocumentTypeModel? _documentTypeModel;
  String? _selectedDocumentTypeId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDocumentTypes();
  }

  Future<void> _fetchDocumentTypes() async {
    final result = await DocumentTypeService.getDocumentTypes();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _documentTypeModel = result['data'] as DocumentTypeModel;
      } else {
        _errorMessage = result['message'] ?? "Failed to load document types";
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedDocumentTypeId != null) {
      final selectedName = _documentTypeModel!.getNameById(_selectedDocumentTypeId!);

      final docData = {
        'document_type_id': _selectedDocumentTypeId!,
        'document_type': selectedName,
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Document',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E5E5), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.description_outlined, color: Color(0xFF014323), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Request Supporting Document',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Specify the document required to proceed with the inquiry.',
                    style: TextStyle(color: Color(0xFF757575), fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  // Document Type Label
                  const Text(
                    'Document Type',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 8),

                  // Tiny Green Loader (exactly like before – just color changed)
                  if (_isLoading)
                    const LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: Color(0xFFE0E0E0),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF014323)),
                    )
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ),

                  // Dropdown
                  if (!_isLoading)
                    DropdownButtonFormField<String>(
                      value: _selectedDocumentTypeId,
                      hint: const Text('Choose document type'),
                      validator: (value) => value == null ? 'Please select a document type' : null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF014323), width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: _documentTypeModel?.documentTypes.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList() ??
                          [],
                      onChanged: (value) => setState(() => _selectedDocumentTypeId = value),
                    ),

                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF757575))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submit,
                          icon: const Icon(Icons.send, size: 18),
                          label: const Text('Request', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF014323),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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