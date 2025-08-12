import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  static const String baseUrl = AppConfig.baseUrl;

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  Future<Map<String, dynamic>> createComplaint({
    required String category,
    required String description,
    required LocationData location,
    required String village,
    String? ward,
    String? imageBase64,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.complaintsEndpoint}'),
        headers: headers,
        body: jsonEncode({
          'category': category,
          'description': description,
          'location': location.toJson(),
          'village': village,
          'ward': ward,
          'imageBase64': imageBase64,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'complaint': data,
          'message': 'Complaint created successfully',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create complaint',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getUserComplaints() async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.complaintsEndpoint}/user'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'complaints': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load complaints',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getComplaint(String complaintId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.complaintsEndpoint}/$complaintId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'complaint': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Complaint not found',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to load complaint',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> sendReminder(String complaintId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.complaintsEndpoint}/$complaintId/reminder'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'complaint': data,
          'message': 'Reminder sent successfully',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send reminder',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> addFeedback({
    required String complaintId,
    required String feedback,
    required int rating,
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.complaintsEndpoint}/$complaintId/feedback'),
        headers: headers,
        body: jsonEncode({
          'feedback': feedback,
          'rating': rating,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'complaint': data,
          'message': 'Feedback added successfully',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication required. Please login again.',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add feedback',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}