import 'package:cmit/core/api_service.dart';
import 'package:cmit/core/local_storage.dart';
import 'package:cmit/features/auth/model/login_model.dart';
import 'package:cmit/config/api.dart';

class AuthService {
  /// ✅ **User Login (Updated for API Response Structure)**
  static Future<Map<String, dynamic>> login(LoginModel user) async {
    try {
      final response = await ApiService.post(
        API.login,
        user.toJson(),
        withAuth: false,
      );

      print("🔹 API Login Response: ${response.toString()}");

      // ✅ Check success and extract data
      if (response['success'] == true && response.containsKey('data')) {
        final responseData = response['data'];

        // ✅ Extract user and token directly (no nested 'status' or 'data')
        final userData = responseData['user'];
        final token = responseData['token'];

        // ✅ Save token & user details
        await LocalStorage.saveToken(token);
        await LocalStorage.saveUser(userData);

        return {
          'success': true,
          'message': responseData['message'] ?? "Login successful",
          'token': token,
          'user': userData,
        };
      }

      // Handle failure case
      return {
        'success': false,
        'message': response['data']?['message'] ?? "Invalid email or password."
      };
    } catch (e) {
      print("❌ AuthService: Login Error - $e");
      return {'success': false, 'message': "A network error occurred. Try again."};
    }
  }

  /// ✅ **Check if User is Logged In**
  static Future<bool> isLoggedIn() async {
    try {
      String? token = await LocalStorage.getToken();
      print("🔹 Checking login status. Token found: $token");
      return token != null && token.isNotEmpty;
    } catch (e) {
      print("❌ AuthService: isLoggedIn Error - $e");
      return false;
    }
  }

  /// ✅ **Logout (Ensures API Call & Clears Token)**
  static Future<bool> logout() async {
    try {
      final response = await ApiService.post(API.logout, {}, withAuth: true);

      print("🔹 Logout API Response: $response");

      if (response['success'] == true) {
        await LocalStorage.logout();

        // ✅ Check if token is actually removed
        String? tokenCheck = await LocalStorage.getToken();
        print("🔹 Token after logout: $tokenCheck");

        if (tokenCheck == null || tokenCheck.isEmpty) {
          print("✅ Logout successful & token cleared!");
          return true;
        } else {
          print("❌ Token was not removed properly!");
          return false;
        }
      }

      print("❌ Logout API failed: ${response['message']}");
      return false;
    } catch (e) {
      print("❌ AuthService: Logout Error - $e");
      return false;
    }
  }
}