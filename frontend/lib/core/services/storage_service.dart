import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token management
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(Environment.tokenKey, token);
  }

  static Future<String?> getToken() async {
    return _prefs?.getString(Environment.tokenKey);
  }

  static Future<void> removeToken() async {
    await _prefs?.remove(Environment.tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // User ID management
  static Future<void> saveUserId(String userId) async {
    await _prefs?.setString(Environment.userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    return _prefs?.getString(Environment.userIdKey);
  }

  static Future<void> removeUserId() async {
    await _prefs?.remove(Environment.userIdKey);
  }

  // User role management
  static Future<void> saveUserRole(String role) async {
    await _prefs?.setString(Environment.userRoleKey, role);
  }

  static Future<String?> getUserRole() async {
    return _prefs?.getString(Environment.userRoleKey);
  }

  static Future<void> removeUserRole() async {
    await _prefs?.remove(Environment.userRoleKey);
  }

  // Profile completion status
  static Future<void> saveProfileCompleted(bool completed) async {
    await _prefs?.setBool(Environment.profileCompletedKey, completed);
  }

  static Future<bool> getProfileCompleted() async {
    return _prefs?.getBool(Environment.profileCompletedKey) ?? false;
  }

  static Future<void> removeProfileCompleted() async {
    await _prefs?.remove(Environment.profileCompletedKey);
  }

  // Clear all user data
  static Future<void> clearUserData() async {
    await removeToken();
    await removeUserId();
    await removeUserRole();
    await removeProfileCompleted();
  }

  // Generic storage methods
  static Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    return _prefs?.getString(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  static Future<void> saveInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  static Future<void> saveDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  static Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  static Future<void> saveStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  static Future<List<String>> getStringList(String key) async {
    return _prefs?.getStringList(key) ?? [];
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<bool> containsKey(String key) async {
    return _prefs?.containsKey(key) ?? false;
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}