import 'package:cmit/core/api_service.dart';
import 'package:cmit/config/api.dart';
import 'package:cmit/features/inquiries/model/document_type_model.dart';

class DocumentTypeService {
  static Future<Map<String, dynamic>> getDocumentTypes() async {
    try {
      print("Fetching document types from: ${API.getDocumentTypes}");

      final response = await ApiService.get(
        API.getDocumentTypes,
        withAuth: true,
      );

      print("API DocumentTypes Raw Response: $response");

      if (response['success'] == true && response['data'] != null) {
        final rawData = response['data'];

        if (rawData is Map<String, dynamic> && rawData.containsKey('document_types')) {
          final documentTypeModel = DocumentTypeModel.fromJson(rawData);

          return {
            'success': true,
            'message': "Document types fetched successfully",
            'data': documentTypeModel,
          };
        }
      }

      return {
        'success': false,
        'message': 'Invalid response format from server',
      };
    } catch (e, stackTrace) {
      print("DocumentTypeService Error: $e\nStackTrace: $stackTrace");
      return {
        'success': false,
        'message': "Failed to load document types. Please try again.",
      };
    }
  }
}