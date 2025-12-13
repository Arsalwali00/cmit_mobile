// features/inquiries/model/annex_model.dart

class AnnexModel {
  final int id;
  final String title;
  final int inquiryId;
  final String? createdAt;
  final String? updatedAt;

  AnnexModel({
    required this.id,
    required this.title,
    required this.inquiryId,
    this.createdAt,
    this.updatedAt,
  });

  factory AnnexModel.fromJson(Map<String, dynamic> json) {
    return AnnexModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      inquiryId: json['inquiry_id'] ?? json['inquiryId'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "inquiry_id": inquiryId,
    };
  }
}