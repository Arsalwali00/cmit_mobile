import 'dart:convert';

class AssignToMeModel {
  final int id;
  final String inquiryRequestId;
  final String title;
  final String description;
  final String tors;
  final String departmentId;
  final String initiatorId;
  final String timeFrame;
  final String priority;
  final String inquiryTypeId;
  final String recommenderId;
  final String assignedToId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<TeamMember> teamMembers;
  final InquiryType inquiryType;
  final Department department;
  final User initiator;
  final User recommender;
  final User assignedTo;

  AssignToMeModel({
    required this.id,
    required this.inquiryRequestId,
    required this.title,
    required this.description,
    required this.tors,
    required this.departmentId,
    required this.initiatorId,
    required this.timeFrame,
    required this.priority,
    required this.inquiryTypeId,
    required this.recommenderId,
    required this.assignedToId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.teamMembers,
    required this.inquiryType,
    required this.department,
    required this.initiator,
    required this.recommender,
    required this.assignedTo,
  });

  /// ✅ Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inquiry_request_id': inquiryRequestId,
      'title': title,
      'description': description,
      'tors': tors,
      'department_id': departmentId,
      'initiator_id': initiatorId,
      'time_frame': timeFrame,
      'priority': priority,
      'inquiry_type_id': inquiryTypeId,
      'recommender_id': recommenderId,
      'assigned_to_id': assignedToId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'team_members': teamMembers.map((member) => member.toJson()).toList(),
      'inquiry_type': inquiryType.toJson(),
      'department': department.toJson(),
      'initiator': initiator.toJson(),
      'recommender': recommender.toJson(),
      'assigned_to': assignedTo.toJson(),
    };
  }

  /// ✅ Factory Constructor to Map API Response
  factory AssignToMeModel.fromJson(Map<String, dynamic> json) {
    return AssignToMeModel(
      id: int.parse(json['id'].toString()),
      inquiryRequestId: json['inquiry_request_id']?.toString() ?? json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tors: json['tors'] ?? '',
      departmentId: json['department_id']?.toString() ?? '0',
      initiatorId: json['initiator_id']?.toString() ?? '0',
      timeFrame: json['time_frame'] ?? '',
      priority: json['priority'].toString(),
      inquiryTypeId: json['inquiry_type_id']?.toString() ?? '0',
      recommenderId: json['recommender_id']?.toString() ?? '0',
      assignedToId: json['assigned_to_id']?.toString() ?? '0',
      status: json['status'].toString(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      teamMembers: (json['team_members'] as List<dynamic>?)
          ?.map((item) => TeamMember.fromJson({'name': item.toString()}))
          .toList() ??
          [],
      inquiryType: InquiryType.fromJson(
          json['inquiry_type'] is Map ? json['inquiry_type'] : {'name': json['inquiry_type'] ?? ''}),
      department: Department.fromJson(
          json['department'] is Map ? json['department'] : {'name': json['department'] ?? ''}),
      initiator: User.fromJson(json['initiator'] is Map ? json['initiator'] : {'name': json['initiator'] ?? ''}),
      recommender: User.fromJson(
          json['recommender'] is Map ? json['recommender'] : {'name': json['recommender'] ?? ''}),
      assignedTo: User.fromJson(
          json['assigned_to'] is Map ? json['assigned_to'] : {'name': json['assigned_to'] ?? ''}),
    );
  }
}

class TeamMember {
  final int id;
  final String inquiryId;
  final String userId;
  final String role;
  final String createdAt;
  final String updatedAt;
  final User user;

  TeamMember({
    required this.id,
    required this.inquiryId,
    required this.userId,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inquiry_id': inquiryId,
      'user_id': userId,
      'role': role,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user.toJson(),
    };
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: int.parse(json['id']?.toString() ?? '0'),
      inquiryId: json['inquiry_id']?.toString() ?? '0',
      userId: json['user_id']?.toString() ?? '0',
      role: json['role'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: User.fromJson(json['user'] is Map ? json['user'] : {'name': json['name'] ?? ''}),
    );
  }
}

class InquiryType {
  final int id;
  final String name;
  final String code;
  final String createdAt;
  final String updatedAt;

  InquiryType({
    required this.id,
    required this.name,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory InquiryType.fromJson(Map<String, dynamic> json) {
    return InquiryType(
      id: int.parse(json['id']?.toString() ?? '0'),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Department {
  final int id;
  final String name;
  final String code;
  final String createdAt;
  final String updatedAt;

  Department({
    required this.id,
    required this.name,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: int.parse(json['id']?.toString() ?? '0'),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class User {
  final int id;
  final String designationId;
  final String? departmentId;
  final String name;
  final String cnicNumber;
  final String cellNumber;
  final String email;
  final String? signature;
  final String? emailVerifiedAt;
  final String? profilePicture;
  final String status;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.designationId,
    this.departmentId,
    required this.name,
    required this.cnicNumber,
    required this.cellNumber,
    required this.email,
    this.signature,
    this.emailVerifiedAt,
    this.profilePicture,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'designation_id': designationId,
      'department_id': departmentId,
      'name': name,
      'cnic_number': cnicNumber,
      'cell_number': cellNumber,
      'email': email,
      'signature': signature,
      'email_verified_at': emailVerifiedAt,
      'profile_picture': profilePicture,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id']?.toString() ?? '0'),
      designationId: json['designation_id']?.toString() ?? '0',
      departmentId: json['department_id']?.toString(),
      name: json['name'] ?? '',
      cnicNumber: json['cnic_number'] ?? '',
      cellNumber: json['cell_number'] ?? '',
      email: json['email'] ?? '',
      signature: json['signature'],
      emailVerifiedAt: json['email_verified_at'],
      profilePicture: json['profile_picture'],
      status: json['status']?.toString() ?? '0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}