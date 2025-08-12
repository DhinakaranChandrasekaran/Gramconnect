import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';

class SuperAdminService {
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

  Future<void> createAdmin({
    required String email,
    required String password,
    required String fullName,
    String role = 'VILLAGE_ADMIN',
  }) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/admin/create'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
        }),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to create admin');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> promoteUserToAdmin(String userId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/admin/promote/$userId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to promote user');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getAllAdmins() async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/admin/list'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load admins');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getAllUsers() async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/users/admin/all'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> updateAdminRole(String adminId, String newRole) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/admin/$adminId/role'),
        headers: headers,
        body: jsonEncode({'role': newRole}),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to update admin role');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> deactivateAdmin(String adminId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/admin/$adminId/deactivate'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to deactivate admin');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> activateAdmin(String adminId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/admin/$adminId/activate'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to activate admin');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}