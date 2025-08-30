import 'package:cmit/core/calculator_service.dart';
import 'package:cmit/features/home/model/calculator_model.dart';

class CalculatorPresenter {
  /// ✅ **Calculate Race Time Predictions**
  Future<Map<String, dynamic>> calculate(CalculatorModel input) async {
    try {
      final response = await CalculatorService.calculate(input);

      print("🔹 CalculatorPresenter Calculate Response: ${response.toString()}");

      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? "Calculation successful!",
          'data': response['data'],
        };
      }

      return {
        'success': false,
        'message': response['message'] ?? "Calculation failed.",
      };
    } catch (e) {
      print("❌ CalculatorPresenter: Calculate Error - $e");
      return {
        'success': false,
        'message': "An unexpected error occurred. Try again.",
      };
    }
  }
}