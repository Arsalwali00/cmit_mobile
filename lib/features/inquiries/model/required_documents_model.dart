class RequiredDocumentsResponse {
  final bool success;
  final String message;
  final dynamic data; // You can make this more specific once you see the actual response

  RequiredDocumentsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RequiredDocumentsResponse.fromJson(Map<String, dynamic> json) {
    return RequiredDocumentsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}