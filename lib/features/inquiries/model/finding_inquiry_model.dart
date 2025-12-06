class FindingInquiryModel {
  final String findings;
  final int visitId;

  FindingInquiryModel({
    required this.findings,
    required this.visitId,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      "findings": findings,
      "visit_id": visitId,
    };
  }

  /// Optional: Parse response if API returns the saved finding
  factory FindingInquiryModel.fromJson(Map<String, dynamic> json) {
    return FindingInquiryModel(
      findings: json['findings'] ?? '',
      visitId: json['visit_id'] ?? 0,
    );
  }
}