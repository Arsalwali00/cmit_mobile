// file: model/annex_file_upload_model.dart

class AnnexFileUploadResponse {
  final bool success;
  final String message;
  final dynamic data; // You can make this more specific once you know the exact response structure

  AnnexFileUploadResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AnnexFileUploadResponse.fromJson(Map<String, dynamic> json) {
    return AnnexFileUploadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown response',
      data: json['data'],
    );
  }
}