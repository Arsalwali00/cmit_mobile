import 'package:cmit/core/api_service.dart';
import 'package:cmit/config/api.dart';
import 'package:cmit/features/home/model/calculator_model.dart';

class CalculatorService {
  /// ✅ **Calculate Race Time Predictions**
  static Future<Map<String, dynamic>> calculate(CalculatorModel input) async {
    try {
      print("🔹 Sending calculator request: ${input.toJson()}");

      final response = await ApiService.post(
        API.calculator,
        input.toJson(),
        withAuth: true, // Include Sanctum token
      );

      print("🔹 API Calculator Response: $response");

      // ✅ Handle response
      if (response['success'] == true && response.containsKey('data')) {
        final responseData = response['data'];

        // ✅ Verify response structure
        if (responseData.containsKey('input_distance') &&
            responseData.containsKey('input_time') &&
            responseData.containsKey('predictions')) {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Calculation successful',
            'data': {
              'input_distance': responseData['input_distance'],
              'input_time': responseData['input_time'],
              'predictions': responseData['predictions'],
            },
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid response format from server.',
          };
        }
      }

      return {
        'success': false,
        'message': response['data']['message'] ?? 'Calculation failed.',
      };
    } catch (e) {
      print("❌ CalculatorService: Calculate Error - $e");
      return {
        'success': false,
        'message': 'A network error occurred. Please try again.',
      };
    }
  }
}