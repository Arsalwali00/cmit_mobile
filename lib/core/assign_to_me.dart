import 'package:cmit/core/api_service.dart';
import 'package:cmit/config/api.dart';
import 'package:cmit/features/home/model/assign_to_me_model.dart';

class AssignToMe {
  /// ✅ Fetch Inquiries Assigned to User
  static Future<Map<String, dynamic>> getAssignedInquiries() async {
    try {
      print("🔹 Fetching assigned inquiries from: ${API.assignToMe}");
      final response = await ApiService.get(
        API.assignToMe,
        withAuth: true,
      );

      print("🔹 API AssignToMe Response: ${response.toString()}");

      // ✅ Check success and extract data
      if (response['success'] == true && response.containsKey('data')) {
        // Access the nested 'data' field
        final nestedData = response['data'] as Map<String, dynamic>;
        if (nestedData['success'] == true && nestedData.containsKey('data')) {
          final responseData = nestedData['data'] as List<dynamic>;

          // ✅ Convert list of inquiries to AssignToMeModel
          final inquiries = responseData
              .map((json) => AssignToMeModel.fromJson(json as Map<String, dynamic>))
              .toList();

          return {
            'success': true,
            'message': "Inquiries fetched successfully",
            'inquiries': inquiries,
          };
        }

        // Handle case where nested data is invalid
        return {
          'success': false,
          'message': nestedData['message'] ?? "Failed to fetch assigned inquiries."
        };
      }

      // Handle failure case
      return {
        'success': false,
        'message': response['message'] ?? "Failed to fetch assigned inquiries."
      };
    } catch (e, stackTrace) {
      print("❌ AssignToMe: GetAssignedInquiries Error - $e\nStackTrace: $stackTrace");
      return {'success': false, 'message': "A network error occurred. Please try again."};
    }
  }
}