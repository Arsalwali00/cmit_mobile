class RequiredDocumentUploadModel {
  final int requiredDocumentId;
  final int documentTypeId;
  final String attachment; // base64 string

  RequiredDocumentUploadModel({
    required this.requiredDocumentId,
    required this.documentTypeId,
    required this.attachment,
  });

  Map<String, dynamic> toJson() {
    return {
      "required_document_id": requiredDocumentId,
      "document_type_id": documentTypeId,
      "attachment": attachment,
    };
  }
}