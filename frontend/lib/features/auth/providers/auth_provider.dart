import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userId;
  String? _userRole;
  bool _profileCompleted = false;
  String? _error;

  // OTP verification state
  bool _showOtpVerification = false;
  String _otpIdentifier = '';
  String _otpType = '';
  int _otpResendCooldown = 0;
  String? _developmentOtp;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userRole => _userRole;
  bool get profileCompleted => _profileCompleted;
  String? get error => _error;
  bool get showOtpVerification => _showOtpVerification;
  String get otpIdentifier => _otpIdentifier;
  String get otpType => _otpType;
  int get otpResendCooldown => _otpResendCooldown;
  String? get developmentOtp => _developmentOtp;

  // Check authentication status
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        final userInfo = await _authService.getCurrentUserInfo();
        _userId = userInfo['userId'];
        _userRole = userInfo['role'];
        _profileCompleted = userInfo['profileCompleted'] ?? false;
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _setError('Failed to check authentication status');
    } finally {
      _setLoading(false);
    }
  }

  // Sign up - OTP sent to phone number only
  Future<bool> signup({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signup(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      if (result.isSuccess) {
        // For signup, always send OTP to phone number
        _prepareOtpVerification(
          identifier: phoneNumber,
          type: 'PHONE',
        );

        // Store development OTP if available
        _developmentOtp = result.otp;
        return true;
      } else {
        _setError(result.error ?? 'Signup failed');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login - OTP sent to email or phone based on input
  Future<bool> login({
    required String identifier,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(
        email: identifier,
      );

      if (result.isSuccess) {
        // Login generates OTP, so prepare for OTP verification
        _prepareOtpVerification(
          identifier: identifier,
          type: _isEmail(identifier) ? 'EMAIL' : 'PHONE',
        );

        // Store development OTP if available
        _developmentOtp = result.otp;
        return true;
      } else {
        _setError(result.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Admin Login (separate method for password-based admin login)
  Future<bool> adminLogin({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.adminLogin(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        _userId = result.userId;
        _userRole = result.role;
        _profileCompleted = result.profileCompleted ?? false;
        _isAuthenticated = true;
        return true;
      } else {
        _setError(result.error ?? 'Admin login failed');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Generate OTP
  Future<bool> generateOtp({
    required String identifier,
    required String type,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.generateOtp(
        identifier: identifier,
        type: type,
      );

      if (result.isSuccess) {
        _prepareOtpVerification(
          identifier: identifier,
          type: type,
        );

        // Store development OTP
        _developmentOtp = result.otp;
        return true;
      } else {
        _setError(result.error ?? 'Failed to generate OTP');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP
  Future<bool> verifyOtp({
    required String identifier,
    required String type,
    required String otp,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.verifyOtp(
        identifier: identifier,
        type: type,
        otp: otp,
      );

      if (result.isSuccess) {
        _userId = result.userId;
        _userRole = result.role;
        _profileCompleted = result.profileCompleted ?? false;
        _isAuthenticated = true;
        _showOtpVerification = false;
        return true;
      } else {
        _setError(result.error ?? 'OTP verification failed');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP
  Future<bool> resendOtp() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.resendOtp(
        identifier: _otpIdentifier,
        type: _otpType,
      );

      if (result.isSuccess) {
        _startResendCooldown();

        // Store development OTP
        _developmentOtp = result.otp;
        return true;
      } else {
        _setError(result.error ?? 'Failed to resend OTP');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In
  Future<bool> googleSignIn(String idToken) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.googleSignIn(idToken);

      if (result.isSuccess) {
        _userId = result.userId;
        _userRole = result.role;
        _profileCompleted = result.profileCompleted ?? false;
        _isAuthenticated = true;
        return true;
      } else {
        _setError(result.error ?? 'Google Sign-In failed');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _userId = null;
    _userRole = null;
    _profileCompleted = false;
    _isAuthenticated = false;
    _showOtpVerification = false;
    notifyListeners();
  }

  // Prepare OTP verification
  void _prepareOtpVerification({
    required String identifier,
    required String type,
  }) {
    _otpIdentifier = identifier;
    _otpType = type;
    _showOtpVerification = true;
    notifyListeners();
  }

  // Start resend cooldown
  void _startResendCooldown() {
    _otpResendCooldown = 60;
    notifyListeners();

    _countdown();
  }

  void _countdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_otpResendCooldown > 0) {
        _otpResendCooldown--;
        notifyListeners();
        _countdown();
      }
    });
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

  void setError(String error) {
    _setError(error);
  }

  void backToAuth() {
    _showOtpVerification = false;
    notifyListeners();
  }

  bool _isEmail(String input) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
  }
}