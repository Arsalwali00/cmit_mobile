class VehicleDriverModel {
  final Map<String, String> drivers;
  final Map<String, String> vehicles;

  VehicleDriverModel({
    required this.drivers,
    required this.vehicles,
  });

  factory VehicleDriverModel.fromJson(Map<String, dynamic> json) {
    return VehicleDriverModel(
      drivers: _parseMap(json['drivers']),
      vehicles: _parseMap(json['vehicles']),
    );
  }

  static Map<String, String> _parseMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }

  Map<String, dynamic> toJson() {
    return {
      "drivers": drivers,
      "vehicles": vehicles,
    };
  }
}