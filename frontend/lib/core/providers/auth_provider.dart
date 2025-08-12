import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
Future<Map<String, dynamic>> adminLogin({
  required String email,
  required String password,
  bool aadhaarVerified = false,
}) async {
  try {
    _isLoading = true;
    notifyListeners();

    final response = await _authService.adminLogin(
      email: email,
      password: password,
      aadhaarVerified: aadhaarVerified,
    );

    if (response['success'] == true) {
      if (response['requiresOtpVerification'] != true) {
        _token = response['token'];
        // Create admin user model
        final adminData = response['admin'];
        _user = UserModel(
          id: adminData['userId'],
          fullName: adminData['fullName'],
          email: adminData['email'],
          authType: 'ADMIN',
          createdAt: DateTime.now(),
          profileCompleted: true,
        );
        _isLoggedIn = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConfig.tokenKey, _token!);
        await prefs.setString(AppConfig.userKey, jsonEncode(_user!.toJson()));
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } else {
      _isLoading = false;
      notifyListeners();
      return response;
    }
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    return {
      'success': false,
      'message': 'Admin login failed: ${e.toString()}',
    };
  }
}
import '../config/app_config.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  final AuthService _authService = AuthService();

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConfig.tokenKey);

    if (_token != null) {
      final userJson = prefs.getString(AppConfig.userKey);
      if (userJson != null) {
        try {
          final userData = Map<String, dynamic>.from(
            // Parse user data from JSON string
              {'token': _token, 'user': userJson}
          );
          _user = UserModel.fromJson(userData);
          _isLoggedIn = true;
        } catch (e) {
          // Clear invalid data
          await clearAuth();
        }
      }
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final isEmail = identifier.contains('@');
      final response = await _authService.login(
        email: isEmail ? identifier : null,
        phoneNumber: !isEmail ? identifier : null,
        password: password,
        authType: 'PASSWORD',
      );

      if (response['success'] == true) {
        if (response['requiresOtpVerification'] != true) {
          _token = response['token'];
          _user = UserModel.fromJson(response['user']);
          _isLoggedIn = true;

          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConfig.tokenKey, _token!);
          await prefs.setString(AppConfig.userKey, response['user'].toString());
        }

        _isLoading = false;
        notifyListeners();
        return response;
      } else {
        _isLoading = false;
        notifyListeners();
        return response;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.register(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      if (response['success'] == true) {
        if (response['requiresOtpVerification'] != true) {
          _token = response['token'];
          _user = UserModel.fromJson(response['user']);
          _isLoggedIn = true;

          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConfig.tokenKey, _token!);
          await prefs.setString(AppConfig.userKey, response['user'].toString());
        }

        _isLoading = false;
        notifyListeners();
        return response;
      } else {
        _isLoading = false;
        notifyListeners();
        return response;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  Future<bool> verifyOtp({
    required String identifier,
    required String otp,
    required String type,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _authService.verifyOtp(
        identifier: identifier,
        otp: otp,
        type: type,
      );

      if (response['success'] == true) {
        _token = response['token'];
        _user = UserModel.fromJson(response['user']);
        _isLoggedIn = true;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConfig.tokenKey, _token!);
        await prefs.setString(AppConfig.userKey, response['user'].toString());

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await clearAuth();
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> clearAuth() async {
    _user = null;
    _token = null;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userKey);

    notifyListeners();
  }

  Future<bool> resendOtp({
    required String identifier,
    required String type,
  }) async {
    try {
      final response = await _authService.resendOtp(
        identifier: identifier,
        type: type,
      );
      return response['success'] == true;
    } catch (e) {
      throw Exception('Failed to resend OTP: ${e.toString()}');
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    required String district,
    required String panchayat,
    required String ward,
    required String homeAddress,
    String? aadhaarNumber,
  }) async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Call backend to update MongoDB
      final response = await _authService.updateProfile(
        district: district,
        panchayat: panchayat,
        ward: ward,
        homeAddress: homeAddress,
        aadhaarNumber: aadhaarNumber ?? '',
      );

      if (response['success'] == false) {
        throw Exception(response['message'] ?? 'Profile update failed');
      }

      // Update local model
      _user = _user!.copyWith(
        fullName: fullName ?? _user!.fullName,
        email: email ?? _user!.email,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
        district: district,
        panchayat: panchayat,
        ward: ward,
        homeAddress: homeAddress,
        aadhaarNumber: aadhaarNumber,
        profileCompleted: true,
        updatedAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.userKey, jsonEncode(_user!.toJson()));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }
}