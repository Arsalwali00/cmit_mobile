class FinalizedFindingModel {
  final String combinedFindings;
  final int visitId;

  FinalizedFindingModel({
    required this.combinedFindings,
    required this.visitId,
  });

  factory FinalizedFindingModel.fromJson(Map<String, dynamic> json) {
    return FinalizedFindingModel(
      combinedFindings: json['combined_findings'] as String? ?? '',
      visitId: json['visit_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'combined_findings': combinedFindings,
      'visit_id': visitId,
    };
  }
}