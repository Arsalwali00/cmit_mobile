import 'package:cmit/core/api_service.dart';
import 'package:cmit/config/api.dart';
import 'package:cmit/features/inquiries/model/vehicle_driver_model.dart';

class VehicleDriverService {
  /// Fetch Drivers & Vehicles List - FIXED FOR YOUR REAL API RESPONSE
  static Future<Map<String, dynamic>> getVehicleDriverData() async {
    try {
      print("Fetching vehicle & driver data from: ${API.getVehicleDriverData}");

      final response = await ApiService.get(
        API.getVehicleDriverData,
        withAuth: true,
      );

      print("API VehicleDriver Raw Response: $response");

      // Your API returns:
      // { success: true, data: { drivers: {...}, vehicles: {...} } }
      if (response['success'] == true && response.containsKey('data')) {
        final rawData = response['data'];

        // Check if 'data' is a map and has both 'drivers' and 'vehicles'
        if (rawData is Map<String, dynamic> &&
            rawData.containsKey('drivers') &&
            rawData.containsKey('vehicles')) {

          // Parse directly into model
          final result = VehicleDriverModel.fromJson(rawData);

          return {
            'success': true,
            'message': "Vehicle and driver data fetched successfully",
            'data': result,
          };
        }
      }

      // If structure doesn't match expected format
      return {
        'success': false,
        'message': 'Invalid response format from server',
      };
    } catch (e, stackTrace) {
      print("VehicleDriverService Error: $e\nStackTrace: $stackTrace");
      return {
        'success': false,
        'message': "Network error. Please try again.",
      };
    }
  }
}