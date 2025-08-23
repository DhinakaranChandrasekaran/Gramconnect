import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/env.dart';

class GarbageProvider with ChangeNotifier {
  final ApiService _apiService;

  GarbageProvider(this._apiService);

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> _missedPickups = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get schedules => _schedules;
  List<Map<String, dynamic>> get missedPickups => _missedPickups;

  // Fetch garbage schedules
  Future<void> fetchSchedules({
    String? district,
    String? panchayat,
    String? village,
    String? ward,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final queryParams = <String, String>{};
      if (district != null) queryParams['district'] = district;
      if (panchayat != null) queryParams['panchayat'] = panchayat;
      if (village != null) queryParams['village'] = village;
      if (ward != null) queryParams['ward'] = ward;

      final response = await _apiService.get(
        Environment.schedulesEndpoint,
        queryParameters: queryParams,
      );

      if (response.isSuccess) {
        _schedules = List<Map<String, dynamic>>.from(response.data);
      } else {
        _setError(response.error ?? 'Failed to fetch schedules');
      }
    } catch (e) {
      _setError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  // Report missed pickup
  Future<bool> reportMissedPickup({
    required String scheduleId,
    required String village,
    String? note,
    double? lat,
    double? lng,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        Environment.missedPickupsEndpoint,
        {
          'scheduleId': scheduleId,
          'village': village,
          if (note != null && note.isNotEmpty) 'note': note,
          if (lat != null && lng != null) 
            'location': {
              'lat': lat,
              'lng': lng,
            },
        },
      );

      if (response.isSuccess) {
        await fetchMyMissedPickups(); // Refresh the list
        return true;
      } else {
        _setError(response.error ?? 'Failed to report missed pickup');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch user's missed pickups
  Future<void> fetchMyMissedPickups() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get('${Environment.missedPickupsEndpoint}/my');

      if (response.isSuccess) {
        _missedPickups = List<Map<String, dynamic>>.from(response.data);
      } else {
        _setError(response.error ?? 'Failed to fetch missed pickups');
      }
    } catch (e) {
      _setError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  // Get next pickup for a schedule
  DateTime? getNextPickup(Map<String, dynamic> schedule) {
    try {
      final List<String> days = List<String>.from(schedule['days'] ?? []);
      final String timeStr = schedule['time'] ?? '07:00';
      
      if (days.isEmpty) return null;

      final now = DateTime.now();
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

      // Map day strings to DateTime weekday values
      final dayMap = {
        'MON': 1, 'TUE': 2, 'WED': 3, 'THU': 4,
        'FRI': 5, 'SAT': 6, 'SUN': 7,
      };

      DateTime? nextPickup;
      
      for (final dayStr in days) {
        final dayOfWeek = dayMap[dayStr];
        if (dayOfWeek == null) continue;

        // Calculate next occurrence of this day
        var targetDate = DateTime(now.year, now.month, now.day, hour, minute);
        while (targetDate.weekday != dayOfWeek || targetDate.isBefore(now)) {
          targetDate = targetDate.add(const Duration(days: 1));
        }

        if (nextPickup == null || targetDate.isBefore(nextPickup)) {
          nextPickup = targetDate;
        }
      }

      return nextPickup;
    } catch (e) {
      return null;
    }
  }

  // Check if pickup is today
  bool isPickupToday(Map<String, dynamic> schedule) {
    final nextPickup = getNextPickup(schedule);
    if (nextPickup == null) return false;

    final now = DateTime.now();
    return nextPickup.year == now.year &&
           nextPickup.month == now.month &&
           nextPickup.day == now.day;
  }

  // Get pickup status text
  String getPickupStatusText(Map<String, dynamic> schedule) {
    if (isPickupToday(schedule)) {
      return 'Today';
    }
    
    final nextPickup = getNextPickup(schedule);
    if (nextPickup == null) return 'No schedule';

    final now = DateTime.now();
    final difference = nextPickup.difference(now).inDays;

    if (difference == 1) {
      return 'Tomorrow';
    } else if (difference <= 7) {
      return 'In $difference days';
    } else {
      return _formatDate(nextPickup);
    }
  }

  // Format date for display
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${date.day} ${months[date.month - 1]}';
  }

  // Get missed pickup status color
  Color getMissedPickupStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.red;
      case 'ACKNOWLEDGED':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get missed pickup status text
  String getMissedPickupStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return 'Open';
      case 'ACKNOWLEDGED':
        return 'Acknowledged';
      case 'RESOLVED':
        return 'Resolved';
      default:
        return status;
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