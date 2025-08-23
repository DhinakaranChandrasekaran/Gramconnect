import 'dart:convert';
import '../config/env.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  // Sign up with email/phone
  Future<AuthResult> signup({
    required String fullName,
    String? email,
    String? phoneNumber,
    String? password,
  }) async {
    final response = await _apiService.post(
      '${Environment.authEndpoint}/signup',
      {
        'fullName': fullName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (password != null) 'password': password,
      },
      includeAuth: false,
    );

    if (response.isSuccess) {
      return AuthResult.success(message: response.data['message']);
    } else {
      return AuthResult.error(response.error ?? 'Signup failed');
    }
  }

  // Login with email and password
  Future<AuthResult> login({
    required String email,
  }) async {
    final response = await _apiService.post(
      '${Environment.authEndpoint}/otp/generate',
      {
        'identifier': email,
        'type': _isEmail(email) ? 'EMAIL' : 'PHONE',
      },
      includeAuth: false,
    );

    if (response.isSuccess) {
      final data = response.data;
      return AuthResult.success(
        message: data['message'],
        otp: Environment.isDevelopment ? data['otp'] : null,
      );
    } else {
      return AuthResult.error(response.error ?? 'Login failed');
    }
  }

  // Admin Login with password
  Future<AuthResult> adminLogin({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      '${Environment.authEndpoint}/admin/login',
      {
        'email': email,
        'password': password,
      },
      includeAuth: false,
    );

    if (response.isSuccess) {
      final data = response.data;
      await _saveAuthData(data);
      return AuthResult.success(
        token: data['token'],
        userId: data['userId'],
        role: data['role'],
        profileCompleted: data['profileCompleted'] ?? false,
      );
    } else {
      return AuthResult.error(response.error ?? 'Admin login failed');
    }
  }

  // Generate OTP
  Future<AuthResult> generateOtp({
    required String identifier,
    required String type,
  }) async {
    final response = await _apiService.post(
      '${Environment.authEndpoint}/otp/generate',
      {
        'identifier': identifier,
        'type': type,
      },
      includeAuth: false,
    );

    if (response.isSuccess) {
      final data = response.data;
      return AuthResult.success(
        message: data['message'],
        otp: Environment.isDevelopment ? data['otp'] : null,
      );
    } else {
      return AuthResult.error(response.error ?? 'Failed to generate OTP');
    }
  }

  // Verify OTP
  Future<AuthResult> verifyOtp({
    required String identifier,
    required String type,
    required String otp,
  }) async {
    final response = await _apiService.post(
      '${Environment.authEndpoint}/otp/verify',
      {
        'identifier': identifier,
        'type': type,
        'otp': otp,
      },
      includeAuth: false,
    );

    if (response.isSuccess) {
      final data = response.data;
      await _saveAuthData(data);
      return AuthResult.success(
        token: data['token'],
        userId: data['userId'],
        role: data['role'],
        profileCompleted: data['profileCompleted'] ?? false,
      );
    } else {
      return AuthResult.error(response.error ?? 'OTP verification failed');
    }
  }

  // Resend OTP
  Future<AuthResult> resendOtp({
    required String identifier,
    required String type,
  }) async {
    final response = await _apiService.post(
      '${Environment.authEndpoint}/otp/resend',
      {
        'identifier': identifier,
        'type': type,
      },
      includeAuth: false,
    );

    if (response.isSuccess) {
      final data = response.data;
      return AuthResult.success(
        message: data['message'],
        otp: Environment.isDevelopment ? data['otp'] : null,
      );
    } else {
      return AuthResult.error(response.error ?? 'Failed to resend OTP');
    }
  }

  // Google Sign-In
  Future<AuthResult> googleSignIn(String idToken) async {
    final response = await _apiService.post(
      '${Environment.authEndpoint}/google',
      {
        'idToken': idToken,
      },
      includeAuth: false,
    );

    if (response.isSuccess) {
      final data = response.data;
      await _saveAuthData(data);
      return AuthResult.success(
        token: data['token'],
        userId: data['userId'],
        role: data['role'],
        profileCompleted: data['profileCompleted'] ?? false,
      );
    } else {
      return AuthResult.error(response.error ?? 'Google Sign-In failed');
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await StorageService.getToken();
    return token != null && token.isNotEmpty;
  }

  // Get current user info from storage
  Future<Map<String, dynamic>> getCurrentUserInfo() async {
    final token = await StorageService.getToken();
    final userId = await StorageService.getUserId();
    final role = await StorageService.getUserRole();
    final profileCompleted = await StorageService.getProfileCompleted();

    return {
      'token': token,
      'userId': userId,
      'role': role,
      'profileCompleted': profileCompleted,
    };
  }

  // Logout
  Future<void> logout() async {
    await StorageService.clearUserData();
  }

  // Save authentication data to storage
  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    if (data['token'] != null) {
      await StorageService.saveToken(data['token']);
    }
    if (data['userId'] != null) {
      await StorageService.saveUserId(data['userId']);
    }
    if (data['role'] != null) {
      await StorageService.saveUserRole(data['role']);
    }
    if (data['profileCompleted'] != null) {
      await StorageService.saveProfileCompleted(data['profileCompleted']);
    }
  }

  bool _isEmail(String input) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
  }
}

class AuthResult {
  final bool success;
  final String? token;
  final String? userId;
  final String? role;
  final bool? profileCompleted;
  final String? message;
  final String? error;
  final String? otp; // For development mode

  AuthResult._({
    required this.success,
    this.token,
    this.userId,
    this.role,
    this.profileCompleted,
    this.message,
    this.error,
    this.otp,
  });

  factory AuthResult.success({
    String? token,
    String? userId,
    String? role,
    bool? profileCompleted,
    String? message,
    String? otp,
  }) {
    return AuthResult._(
      success: true,
      token: token,
      userId: userId,
      role: role,
      profileCompleted: profileCompleted,
      message: message,
      otp: otp,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult._(success: false, error: error);
  }

  bool get isSuccess => success;
  bool get isError => !success;
}