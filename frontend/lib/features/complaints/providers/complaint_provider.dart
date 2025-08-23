import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/env.dart';

class ComplaintProvider with ChangeNotifier {
  final ApiService _apiService;

  ComplaintProvider(this._apiService);

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _complaints = [];
  Map<String, dynamic>? _selectedComplaint;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get complaints => _complaints;
  Map<String, dynamic>? get selectedComplaint => _selectedComplaint;

  // Create complaint
  Future<bool> createComplaint({
    required String category,
    String? title,
    required String description,
    required String district,
    required String panchayat,
    required String village,
    required String ward,
    double? lat,
    double? lng,
    String? imagePath,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        Environment.complaintsEndpoint,
        {
          'category': category,
          if (title != null) 'title': title,
          'description': description,
          'district': district,
          'panchayat': panchayat,
          'village': village,
          'ward': ward,
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
        },
      );

      if (response.isSuccess) {
        await fetchUserComplaints(); // Refresh the list
        return true;
      } else {
        _setError(response.error ?? 'Failed to create complaint');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fetch user complaints
  Future<void> fetchUserComplaints() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get('${Environment.complaintsEndpoint}/user');

      if (response.isSuccess) {
        _complaints = List<Map<String, dynamic>>.from(response.data);
      } else {
        _setError(response.error ?? 'Failed to fetch complaints');
      }
    } catch (e) {
      _setError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  // Get complaint details
  Future<bool> getComplaintDetails(String complaintId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get('${Environment.complaintsEndpoint}/$complaintId');

      if (response.isSuccess) {
        _selectedComplaint = response.data;
        return true;
      } else {
        _setError(response.error ?? 'Failed to fetch complaint details');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if reminder can be sent
  Future<bool> canSendReminder(String complaintId) async {
    try {
      final response = await _apiService.get('${Environment.complaintsEndpoint}/$complaintId/can-remind');

      if (response.isSuccess) {
        return response.data['canRemind'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Send reminder
  Future<bool> sendReminder(String complaintId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        '${Environment.complaintsEndpoint}/$complaintId/reminder',
        {},
      );

      if (response.isSuccess) {
        await fetchUserComplaints(); // Refresh the list
        return true;
      } else {
        _setError(response.error ?? 'Failed to send reminder');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Submit feedback
  Future<bool> submitFeedback({
    required String complaintId,
    required String rating,
    String? note,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final queryParams = {
        'rating': rating,
        if (note != null && note.isNotEmpty) 'note': note,
      };

      final uri = Uri.parse('${Environment.complaintsEndpoint}/$complaintId/feedback')
          .replace(queryParameters: queryParams);

      final response = await _apiService.post(uri.toString(), {});

      if (response.isSuccess) {
        await fetchUserComplaints(); // Refresh the list
        return true;
      } else {
        _setError(response.error ?? 'Failed to submit feedback');
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

  // Get complaint status color
  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get complaint status text
  String getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'RESOLVED':
        return 'Resolved';
      default:
        return status;
    }
  }

  // Get category icon
  IconData getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'GARBAGE':
        return Icons.delete_outline;
      case 'WATER':
        return Icons.water_drop_outlined;
      case 'ELECTRICITY':
        return Icons.electrical_services_outlined;
      case 'DRAINAGE':
        return Icons.settings_input_component_outlined;
      case 'ROAD_DAMAGE':
        return Icons.construction_outlined;
      case 'HEALTH':
        return Icons.local_hospital_outlined;
      case 'TRANSPORT':
        return Icons.directions_bus_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  // Get category display name
  String getCategoryDisplayName(String category) {
    switch (category.toUpperCase()) {
      case 'GARBAGE':
        return 'Garbage Collection';
      case 'WATER':
        return 'Water Supply';
      case 'ELECTRICITY':
        return 'Electricity';
      case 'DRAINAGE':
        return 'Drainage';
      case 'ROAD_DAMAGE':
        return 'Road Damage';
      case 'HEALTH':
        return 'Health Services';
      case 'TRANSPORT':
        return 'Transportation';
      default:
        return category.replaceAll('_', ' ');
    }
  }
}