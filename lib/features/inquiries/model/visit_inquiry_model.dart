class VisitInquiryModel {
  final String visitDate;      // YYYY-MM-DD
  final String visitTime;      // HH:MM (24-hour)
  final int vehicleId;
  final int driverId;
  final int inquiryId;

  VisitInquiryModel({
    required this.visitDate,
    required this.visitTime,
    required this.vehicleId,
    required this.driverId,
    required this.inquiryId,
  });

  /// Convert model to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      "visit_date": visitDate,
      "visit_time": visitTime,
      "vehicle_id": vehicleId,
      "driver_id": driverId,
      "inquiry_id": inquiryId,
    };
  }

  /// Optional: Parse response (if API returns created visit data)
  factory VisitInquiryModel.fromJson(Map<String, dynamic> json) {
    return VisitInquiryModel(
      visitDate: json['visit_date'] ?? '',
      visitTime: json['visit_time'] ?? '',
      vehicleId: json['vehicle_id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      inquiryId: json['inquiry_id'] ?? 0,
    );
  }
}