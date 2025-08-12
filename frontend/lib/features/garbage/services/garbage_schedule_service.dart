import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../models/garbage_schedule_model.dart';

class GarbageScheduleService {
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

  Future<List<GarbageScheduleModel>> getSchedulesByVillage(String village) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/garbage-schedules/village/$village'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => GarbageScheduleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedules (status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<GarbageScheduleModel>> getSchedulesByVillageAndWard(String village, String? ward) async {
    try {
      final headers = await _getAuthHeaders();

      String url = '$baseUrl/garbage-schedules/village/$village';
      if (ward != null && ward.isNotEmpty) {
        url += '/ward/$ward';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => GarbageScheduleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedules (status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> reportMissedPickup(
      String scheduleId,
      String reason,
      String description, {
        DateTime? scheduledDate,
      }) async {
    try {
      final headers = await _getAuthHeaders();

      final body = {
        // Pass the scheduledDate if provided; otherwise, fallback to now (but ideally pass from caller)
        'scheduledDate': (scheduledDate ?? DateTime.now()).toIso8601String(),
        'reason': reason,
        'description': description,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/missed-pickups'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to report missed pickup');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}