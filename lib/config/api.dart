class ApiConfig {
  // Centralized base URL - change this when needed
  static const String _baseUrl = "https://cmit.sata.pk/api/v1";

  // For assets like department_logo
  static const String assetBaseUrl = "$_baseUrl";

  // Full API base URL
  static const String baseApiUrl = _baseUrl;
}

class API {
  // 🔹 Authentication Endpoints
  static const String login = "${ApiConfig.baseApiUrl}/login";
  static const String logout = "${ApiConfig.baseApiUrl}/logout";

  // 🔹 Calculator Endpoint
  static const String calculator = "${ApiConfig.baseApiUrl}/activity";
}
