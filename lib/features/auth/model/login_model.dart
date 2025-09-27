class LoginModel {
  final String email; // Used for email or CNIC
  final String password;
  final bool isEmailLogin; // Flag to determine email or CNIC
  final String? message; // Optional for API responses
  final Map<String, dynamic>? user; // Optional for API responses
  final String? token; // Optional for API responses

  LoginModel({
    required this.email,
    required this.password,
    required this.isEmailLogin,
    this.message,
    this.user,
    this.token,
  });

  /// ✅ Convert Model to JSON for Login Requests
  Map<String, dynamic> toJson() {
    return {
      isEmailLogin ? 'email' : 'cnic_number': email, // Dynamically set key
      'password': password,
    };
  }

  /// ✅ Factory Constructor to Map API Response
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      message: json['message'] ?? "Login successful",
      user: json['data'] is Map<String, dynamic> ? json['data'] : {}, // Handle nested data
      token: json['token'] ?? "",
      email: '', // Not required in response mapping
      password: '', // Not required in response mapping
      isEmailLogin: true, // Default, not used in response
    );
  }
}