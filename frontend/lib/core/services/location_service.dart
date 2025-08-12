import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class LocationService {
  static const String baseUrl = AppConfig.baseUrl;

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  Future<List<String>> getDistricts({String state = 'Tamil Nadu'}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/locations/districts?state=$state'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        print('Failed to load districts: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load districts: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getDistricts: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<String>> getPanchayats(String district) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/locations/panchayats?district=$district'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        print('Failed to load panchayats: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load panchayats: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getPanchayats: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<String>> getWards(String district, String panchayat) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/locations/wards?district=$district&panchayat=$panchayat'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        print('Failed to load wards: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load wards: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getWards: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
