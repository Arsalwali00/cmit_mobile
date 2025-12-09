class DocumentTypeModel {
  final Map<String, String> documentTypes;

  DocumentTypeModel({required this.documentTypes});

  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    final raw = json['document_types'] as Map<String, dynamic>? ?? {};

    final Map<String, String> parsed = raw.map((key, value) =>
        MapEntry(key, value.toString()));

    return DocumentTypeModel(documentTypes: parsed);
  }

  // Optional: Easy access to list of names or IDs
  List<String> get keys => documentTypes.keys.toList();
  List<String> get values => documentTypes.values.toList();

  // Get name by ID
  String getNameById(String id) => documentTypes[id] ?? "Unknown Document Type";

  Map<String, dynamic> toJson() => {"document_types": documentTypes};
}