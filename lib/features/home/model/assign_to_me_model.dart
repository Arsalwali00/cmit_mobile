// lib/features/home/model/assign_to_me_model.dart
// FULLY UPDATED – WITH parsedRecommendations

import 'package:flutter/material.dart';

class AssignToMeModel {
  final int id;
  final String title;
  final String description;
  final String tors;
  final String timeFrame;
  final String priority;        // "1" = Low, "2" = Medium, "3" = High
  final String status;         // "0" = Submitted, etc.
  final String inquiryType;
  final String department;
  final String initiator;
  final String recommender;
  final String assignedTo;
  final List<String> teamMembers;
  final String userRole;         // e.g., "Chairperson", "Member"
  final DateTime createdAt;

  final List<dynamic> recommendations;
  final List<dynamic> visits;

  const AssignToMeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tors,
    required this.timeFrame,
    required this.priority,
    required this.status,
    required this.inquiryType,
    required this.department,
    required this.initiator,
    required this.recommender,
    required this.assignedTo,
    required this.teamMembers,
    required this.userRole,
    required this.createdAt,
    this.recommendations = const [],
    this.visits = const [],
  });

  factory AssignToMeModel.fromJson(Map<String, dynamic> json) {
    return AssignToMeModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: (json['title'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString(),
      tors: (json['tors'] ?? json['tor'] ?? '').toString(),
      timeFrame: (json['time_frame'] ?? json['timeFrame'] ?? '').toString().trim(),
      priority: (json['priority'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      inquiryType: _safeString(json['inquiry_type'] ?? json['inquiryType']),
      department: _safeString(json['department'] ?? json['department_name']),
      initiator: _safeString(json['initiator']),
      recommender: _safeString(json['recommender']),
      assignedTo: _safeString(json['assigned_to'] ?? json['assignedTo']),
      teamMembers: _parseTeamMembers(json['team_members']),
      userRole: (json['user_role'] ?? json['role'] ?? 'Member').toString().trim(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      recommendations: json['recommendations'] ?? [],
      visits: json['visits'] ?? [],
    );
  }

  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is Map) return (value['name'] ?? value['title'] ?? '').toString().trim();
    return value.toString().trim();
  }

  static List<String> _parseTeamMembers(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map<String>((item) {
      if (item is String) return item.trim();
      if (item is Map) {
        return (item['name'] ??
            item['user']?['name'] ??
            item['full_name'] ??
            '')
            .toString()
            .trim();
      }
      return '';
    }).where((name) => name.isNotEmpty).toList();
  }
}

// EXTENSION WITH ALL GOODIES + NEW parsedRecommendations
extension AssignToMeModelX on AssignToMeModel {
  bool get isChairperson => userRole.toLowerCase().contains('chair');

  String get statusText => switch (status) {
    '0' => 'Submitted',
    '1' => 'Recommended',
    '2' => 'Assigned',
    '3' => 'Under Review',
    '4' => 'Completed',
    '5' => 'Rejected',
    _ => 'Unknown',
  };

  String get priorityText => switch (priority) {
    '1' => 'Low',
    '2' => 'Medium',
    '3' => 'High',
    _ => 'Normal',
  };

  Color get statusColor => switch (status) {
    '0' => Colors.purple.shade600,
    '1' => Colors.cyan.shade700,
    '2' => Colors.blue.shade700,
    '3' => Colors.orange.shade700,
    '4' => Colors.green.shade700,
    '5' => Colors.red.shade700,
    _ => Colors.grey.shade600,
  };

  Color get priorityColor => switch (priority) {
    '1' => Colors.green.shade600,
    '2' => Colors.orange.shade700,
    '3' => Colors.red.shade700,
    _ => Colors.grey.shade600,
  };

  String get formattedDate =>
      '${createdAt.day.toString().padLeft(2, '0')}/'
          '${createdAt.month.toString().padLeft(2, '0')}/'
          '${createdAt.year}';

  // NEW: Clean, safe parsing for recommendations
  List<Map<String, String>> get parsedRecommendations {
    return recommendations.map((item) {
      if (item is Map<String, dynamic>) {
        return {
          'recommendation':
          (item['recommendation'] ?? item['text'] ?? item['description'] ?? '')
              .toString()
              .trim(),
          'penalty_imposed':
          (item['penalty_imposed'] ?? item['penalty'] ?? 'None')
              .toString()
              .trim(),
        };
      }
      // Old format: just a string
      return {
        'recommendation': item.toString().trim(),
        'penalty_imposed': 'None',
      };
    }).toList();
  }
}