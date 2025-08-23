import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/env.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService;

  ProfileProvider(this._apiService);

  bool _isLoading = false;
  String? _error;
  bool _aadhaarVerified = false;
  String? _developmentOtp;
  Map<String, dynamic>? _userProfile;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get aadhaarVerified => _aadhaarVerified;
  String? get developmentOtp => _developmentOtp;
  Map<String, dynamic>? get userProfile => _userProfile;

  // Generate Aadhaar OTP
  Future<bool> generateAadhaarOtp(String aadhaarNumber) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        '${Environment.authEndpoint}/aadhaar/generate',
        {
          'aadhaarNumber': aadhaarNumber,
        },
      );

      if (response.isSuccess) {
        // Store development OTP if available
        _developmentOtp = response.data['otp'];
        return true;
      } else {
        _setError(response.error ?? 'Failed to generate Aadhaar OTP');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify Aadhaar OTP
  Future<bool> verifyAadhaarOtp(String aadhaarNumber, String otp) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        '${Environment.authEndpoint}/aadhaar/verify',
        {
          'aadhaarNumber': aadhaarNumber,
          'otp': otp,
        },
      );

      if (response.isSuccess) {
        _aadhaarVerified = true;
        return true;
      } else {
        _setError(response.error ?? 'Aadhaar OTP verification failed');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Complete profile
  Future<bool> completeProfile({
    required String district,
    required String panchayat,
    required String village,
    required String ward,
    required String homeAddress,
    required String aadhaarNumber,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.put(
        '${Environment.usersEndpoint}/me',
        {
          'district': district,
          'panchayat': panchayat,
          'village': village,
          'ward': ward,
          'homeAddress': homeAddress,
          'aadhaarNumber': aadhaarNumber,
        },
      );

      if (response.isSuccess) {
        _userProfile = response.data;
        return true;
      } else {
        _setError(response.error ?? 'Failed to complete profile');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch user profile
  Future<void> fetchUserProfile() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get('${Environment.usersEndpoint}/me');

      if (response.isSuccess) {
        _userProfile = response.data;
        _aadhaarVerified = response.data['aadhaarVerified'] ?? false;
      } else {
        _setError(response.error ?? 'Failed to fetch profile');
      }
    } catch (e) {
      _setError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? district,
    String? panchayat,
    String? village,
    String? ward,
    String? homeAddress,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['fullName'] = fullName;
      if (district != null) updateData['district'] = district;
      if (panchayat != null) updateData['panchayat'] = panchayat;
      if (village != null) updateData['village'] = village;
      if (ward != null) updateData['ward'] = ward;
      if (homeAddress != null) updateData['homeAddress'] = homeAddress;

      final response = await _apiService.put(
        '${Environment.usersEndpoint}/me',
        updateData,
      );

      if (response.isSuccess) {
        _userProfile = response.data;
        return true;
      } else {
        _setError(response.error ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}