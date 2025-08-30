class ChallanReceiptModel {
  final String psid;
  final String departmentName;
  final String consumerDetails;
  final String billMonth;
  final int billYear;
  final String headOfAccount;
  final String description;
  final double amount;
  final String amountInWords;
  final String qrCodeLink;
  final bool? isPaid;

  ChallanReceiptModel({
    required this.psid,
    required this.departmentName,
    required this.consumerDetails,
    required this.billMonth,
    required this.billYear,
    required this.headOfAccount,
    required this.description,
    required this.amount,
    required this.amountInWords,
    required this.qrCodeLink,
    this.isPaid,
  });

  /// Factory constructor with full null safety and type handling
  factory ChallanReceiptModel.fromJson(Map<String, dynamic> json) {
    return ChallanReceiptModel(
      psid: _parseString(json['PSID'], ''),
      departmentName: _parseString(json['department_name'], 'Unknown Department'),
      consumerDetails: _parseString(json['consumer_details'], 'No Name Provided'),
      billMonth: _parseString(json['bill_month'], 'Unknown Month'),
      billYear: _parseInt(json['bill_year'], 0),
      headOfAccount: _parseString(json['head_of_account'], 'No Head of Account'),
      description: _parseString(json['Description'], 'No Description Available'),
      amount: _parseDouble(json['amount'], 0.0),
      amountInWords: _parseString(json['amount_in_words'], 'Zero Only'),
      qrCodeLink: _parseString(json['QR_code_link'], ''),
      isPaid: _parseBool(json['is_paid']),
    );
  }

  /// Convert model to JSON safely
  Map<String, dynamic> toJson() {
    return {
      'PSID': psid,
      'department_name': departmentName,
      'consumer_details': consumerDetails,
      'bill_month': billMonth,
      'bill_year': billYear,
      'head_of_account': headOfAccount,
      'Description': description,
      'amount': amount,
      'amount_in_words': amountInWords,
      'QR_code_link': qrCodeLink,
      'is_paid': isPaid,
    };
  }

  /// Helper method to parse String values
  static String _parseString(dynamic value, String fallback) {
    if (value == null) return fallback;
    return value.toString();
  }

  /// Helper method to parse int values
  static int _parseInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    if (value is num) return value.toInt();
    return fallback;
  }

  /// Helper method to parse double values
  static double _parseDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  /// Helper method to parse bool values
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      if (lowerValue == 'true') return true;
      if (lowerValue == 'false') return false;
    }
    return null; // Fallback to null for unexpected types
  }
}