import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  static const String baseUrl = AppConfig.baseUrl;

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.authEndpoint}/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'authType': 'PHONE_OTP',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'user': data,
          'requiresOtpVerification': data['requiresOtpVerification'] ?? false,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    String? email,
    String? phoneNumber,
    String? password,
    String authType = 'PASSWORD',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.authEndpoint}/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
          'authType': authType,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'user': data,
          'requiresOtpVerification': data['requiresOtpVerification'] ?? false,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String identifier,
    required String otp,
    required String type,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'otp': otp,
        'type': type,
      };

      // Add identifier based on type
      if (identifier.contains('@')) {
        requestBody['email'] = identifier;
      } else {
        requestBody['phoneNumber'] = identifier;
      }

      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.authEndpoint}/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'user': data,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> resendOtp({
    required String identifier,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.authEndpoint}/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'identifier': identifier,
          'type': type,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP resent successfully',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // 1️⃣ Send Aadhaar OTP
  Future<Map<String, dynamic>> sendAadhaarOtp({
    required String aadhaarNumber,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/aadhaar/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aadhaarNumber': aadhaarNumber,
          'phoneNumber': phoneNumber,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'otp': data['otp'], // optional: use for testing
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send Aadhaar OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // 2️⃣ Verify Aadhaar OTP
  Future<Map<String, dynamic>> verifyAadhaarOtp({
    required String aadhaarNumber,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/aadhaar/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aadhaarNumber': aadhaarNumber,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'verified': data['verified'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    required String district,
    required String panchayat,
    required String ward,
    required String homeAddress,
    required String aadhaarNumber,
    bool aadhaarVerified = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token ?? ''}',
        },
        body: jsonEncode({
          'userId': userId,
          'fullName': fullName,
          'district': district,
          'panchayat': panchayat,
          'ward': ward,
          'homeAddress': homeAddress,
          'aadhaarNumber': aadhaarNumber,
          'aadhaarVerified': aadhaarVerified,
          'profileCompleted': true,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Profile update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.authEndpoint}/admin/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'admin': data,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Admin login failed',
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