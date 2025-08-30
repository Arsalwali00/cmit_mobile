class DynamicFormResponse {
  final bool status;
  final List<DepartmentForm> forms;

  DynamicFormResponse({
    required this.status,
    required this.forms,
  });

  /// Convert JSON to `DynamicFormResponse`
  factory DynamicFormResponse.fromJson(Map<String, dynamic> json) {
    return DynamicFormResponse(
      status: json['status'] ?? false,
      forms: (json['data'] as List<dynamic>?)
          ?.map((form) => DepartmentForm.fromJson(form))
          .toList() ??
          [],
    );
  }

  /// Convert `DynamicFormResponse` to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': forms.map((form) => form.toJson()).toList(),
    };
  }
}

class DepartmentForm {
  final int formId; // ✅ Added formId
  final String departmentName;
  final String formName;
  final List<FormFieldAttribute> attributes;
  final List<FeeStructure> feeStructures;

  DepartmentForm({
    required this.formId, // ✅ Ensure this is included
    required this.departmentName,
    required this.formName,
    required this.attributes,
    required this.feeStructures,
  });

  /// Convert JSON to `DepartmentForm`
  factory DepartmentForm.fromJson(Map<String, dynamic> json) {
    return DepartmentForm(
      formId: json['form_id'] ?? 0, // ✅ Extract `formId` from JSON
      departmentName: json['department_name'] ?? "Unknown Department",
      formName: json['form_name'] ?? "Unnamed Form",
      attributes: (json['attributes'] as List<dynamic>?)
          ?.map((attr) => FormFieldAttribute.fromJson(attr))
          .toList() ??
          [],
      feeStructures: (json['fee_structures'] as List<dynamic>?)
          ?.map((fee) => FeeStructure.fromJson(fee))
          .toList() ??
          [],
    );
  }

  /// Convert `DepartmentForm` to JSON
  Map<String, dynamic> toJson() {
    return {
      'form_id': formId, // ✅ Added to ensure form ID is included in API calls
      'department_name': departmentName,
      'form_name': formName,
      'attributes': attributes.map((attr) => attr.toJson()).toList(),
      'fee_structures': feeStructures.map((fee) => fee.toJson()).toList(),
    };
  }
}

class FormFieldAttribute {
  final String attributeName;
  final String label;
  final String inputType;
  final String isRequired;
  final List<String> attributeList;

  FormFieldAttribute({
    required this.attributeName,
    required this.label,
    required this.inputType,
    required this.isRequired,
    required this.attributeList,
  });

  /// Convert JSON to `FormFieldAttribute`
  factory FormFieldAttribute.fromJson(Map<String, dynamic> json) {
    List<String> parsedAttributeList = [];

    if (json['attribute_list'] is List) {
      parsedAttributeList = (json['attribute_list'] as List).map((e) {
        if (e is String) {
          return e;
        } else if (e is Map<String, dynamic> && e.containsKey('value')) {
          return e['value'].toString();
        }
        return '';
      }).where((e) => e.isNotEmpty).toList();
    }

    return FormFieldAttribute(
      attributeName: json['attribute_name'] ?? "",
      label: json['label'] ?? "",
      inputType: json['input_type'] ?? "Text",
      isRequired: json['is_required'] ?? "No",
      attributeList: parsedAttributeList,
    );
  }

  /// Convert `FormFieldAttribute` to JSON
  Map<String, dynamic> toJson() {
    return {
      'attribute_name': attributeName,
      'label': label,
      'input_type': inputType,
      'is_required': isRequired,
      'attribute_list': attributeList.map((e) => {'value': e}).toList(),
    };
  }
}

class FeeStructure {
  final int feeStructureId;
  final String? title;
  final String currency;
  final double amount;

  FeeStructure({
    required this.feeStructureId,
    required this.title,
    required this.currency,
    required this.amount,
  });

  /// Convert JSON to `FeeStructure`
  factory FeeStructure.fromJson(Map<String, dynamic> json) {
    return FeeStructure(
      feeStructureId: json['fee_structure_id'] ?? 0,
      title: json['title'], // Nullable
      currency: json['currency'] ?? "", // Keeps currency dynamic
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert `FeeStructure` to JSON
  Map<String, dynamic> toJson() {
    return {
      'fee_structure_id': feeStructureId,
      'title': title,
      'currency': currency,
      'amount': amount,
    };
  }
}
