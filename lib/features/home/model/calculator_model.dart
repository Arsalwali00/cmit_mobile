class CalculatorModel {
  final String distance;
  final int hours;
  final int minutes;
  final int seconds;
  final String? message; // Optional for API responses
  final String? inputDistance; // Optional for API responses
  final String? inputTime; // Optional for API responses
  final Map<String, dynamic>? predictions; // Optional for API responses

  CalculatorModel({
    required this.distance,
    required this.hours,
    required this.minutes,
    required this.seconds,
    this.message,
    this.inputDistance,
    this.inputTime,
    this.predictions,
  });

  /// ✅ Convert Model to JSON for Calculator Requests
  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }

  /// ✅ Factory Constructor to Map API Response
  factory CalculatorModel.fromJson(Map<String, dynamic> json) {
    return CalculatorModel(
      distance: '', // Not required in response mapping
      hours: 0, // Not required in response mapping
      minutes: 0, // Not required in response mapping
      seconds: 0, // Not required in response mapping
      message: json['message'] ?? 'Calculation successful',
      inputDistance: json['input_distance'] ?? '',
      inputTime: json['input_time'] ?? '',
      predictions: json['predictions'] ?? {},
    );
  }
}