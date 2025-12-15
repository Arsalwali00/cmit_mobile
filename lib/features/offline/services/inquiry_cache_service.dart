// lib/features/offline/services/inquiry_cache_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cmit/features/home/model/assign_to_me_model.dart';

class InquiryCacheService {
  static const String _cacheKey = 'cached_inquiries';
  static const String _cacheTimestampKey = 'cached_inquiries_timestamp';
  static const Duration _cacheValidDuration = Duration(hours: 24);

  /// Cache inquiries to local storage
  static Future<bool> cacheInquiries(List<AssignToMeModel> inquiries) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert inquiries to JSON
      final jsonList = inquiries.map((i) => i.toJson()).toList();

      // Save inquiries
      await prefs.setString(_cacheKey, jsonEncode(jsonList));

      // Save timestamp
      await prefs.setString(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      return true;
    } catch (e) {
      print('Failed to cache inquiries: $e');
      return false;
    }
  }

  /// Load inquiries from cache
  static Future<List<AssignToMeModel>?> getCachedInquiries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);

      if (cachedJson == null) {
        return null;
      }

      final List<dynamic> decoded = jsonDecode(cachedJson);
      final inquiries = decoded
          .map((json) => AssignToMeModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return inquiries;
    } catch (e) {
      print('Failed to load cached inquiries: $e');
      return null;
    }
  }

  /// Check if cache exists
  static Future<bool> hasCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_cacheKey);
    } catch (e) {
      return false;
    }
  }

  /// Get cache age in hours
  static Future<int?> getCacheAge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_cacheTimestampKey);

      if (timestampStr == null) return null;

      final timestamp = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(timestamp);

      return age.inHours;
    } catch (e) {
      print('Failed to get cache age: $e');
      return null;
    }
  }

  /// Check if cache is still valid
  static Future<bool> isCacheValid() async {
    try {
      final age = await getCacheAge();
      if (age == null) return false;

      return age < _cacheValidDuration.inHours;
    } catch (e) {
      return false;
    }
  }

  /// Get cache metadata
  static Future<Map<String, dynamic>> getCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_cacheTimestampKey);
      final cachedJson = prefs.getString(_cacheKey);

      if (timestampStr == null || cachedJson == null) {
        return {
          'has_cache': false,
          'cache_age_hours': null,
          'cache_timestamp': null,
          'cache_valid': false,
          'item_count': 0,
        };
      }

      final timestamp = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(timestamp);
      final List<dynamic> decoded = jsonDecode(cachedJson);

      return {
        'has_cache': true,
        'cache_age_hours': age.inHours,
        'cache_timestamp': timestamp.toIso8601String(),
        'cache_valid': age < _cacheValidDuration,
        'item_count': decoded.length,
      };
    } catch (e) {
      print('Failed to get cache metadata: $e');
      return {
        'has_cache': false,
        'cache_age_hours': null,
        'cache_timestamp': null,
        'cache_valid': false,
        'item_count': 0,
      };
    }
  }

  /// Clear cached inquiries
  static Future<bool> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      return true;
    } catch (e) {
      print('Failed to clear cache: $e');
      return false;
    }
  }

  /// Update a single inquiry in cache (useful after editing)
  static Future<bool> updateCachedInquiry(AssignToMeModel updatedInquiry) async {
    try {
      final inquiries = await getCachedInquiries();
      if (inquiries == null) return false;

      // Find and update the inquiry
      final index = inquiries.indexWhere((i) => i.id == updatedInquiry.id);
      if (index != -1) {
        inquiries[index] = updatedInquiry;
        return await cacheInquiries(inquiries);
      }

      return false;
    } catch (e) {
      print('Failed to update cached inquiry: $e');
      return false;
    }
  }

  /// Remove a single inquiry from cache
  static Future<bool> removeCachedInquiry(int inquiryId) async {
    try {
      final inquiries = await getCachedInquiries();
      if (inquiries == null) return false;

      inquiries.removeWhere((i) => i.id == inquiryId);
      return await cacheInquiries(inquiries);
    } catch (e) {
      print('Failed to remove cached inquiry: $e');
      return false;
    }
  }

  /// Get a single inquiry from cache by ID
  static Future<AssignToMeModel?> getCachedInquiryById(int inquiryId) async {
    try {
      final inquiries = await getCachedInquiries();
      if (inquiries == null) return null;

      return inquiries.firstWhere(
            (i) => i.id == inquiryId,
        orElse: () => throw Exception('Not found'),
      );
    } catch (e) {
      return null;
    }
  }
}