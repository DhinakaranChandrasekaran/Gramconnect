import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';

class AdminService {
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

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getAllComplaints() async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/admin/complaints'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load complaints');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> updateComplaintStatus(String complaintId, String status, String? adminResponse) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/admin/complaints/$complaintId/status'),
        headers: headers,
        body: jsonEncode({
          'status': status,
          'adminResponse': adminResponse,
        }),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to update complaint status');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}