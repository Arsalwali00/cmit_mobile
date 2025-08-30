class ApiConfig {
  // Centralized base URL - change this when needed
  static const String _baseUrl = "http://192.168.18.33:8000";
  static const String assetBaseUrl = "$_baseUrl"; // For assets like department_logo

  // Full API base URL
  static const String baseApiUrl = _baseUrl;
}

class API {
  // 🔹 Authentication Endpoints
  static const String login = "${ApiConfig.baseApiUrl}/api/login";
  static const String logout = "${ApiConfig.baseApiUrl}/api/logout";

  // 🔹 Calculator Endpoint
  static const String calculator = "${ApiConfig.baseApiUrl}/api/calculator";
}