import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import '../services/offline_sync_service.dart';

class ComplaintProvider with ChangeNotifier {
  List<ComplaintModel> _complaints = [];
  List<ComplaintModel> _offlineComplaints = [];
  bool _isLoading = false;
  String? _error;

  List<ComplaintModel> get complaints => _complaints;
  List<ComplaintModel> get offlineComplaints => _offlineComplaints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ComplaintService _complaintService = ComplaintService();
  final OfflineService _offlineService = OfflineService();

  ComplaintProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await loadOfflineComplaints();
    await syncOfflineComplaints();
  }

  Future<void> loadComplaints() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _complaintService.getUserComplaints();

      if (result['success'] == true) {
        _complaints = (result['complaints'] as List)
            .map((json) => ComplaintModel.fromJson(json))
            .toList();
      } else {
        _error = result['message'] ?? 'Failed to load complaints';
      }
    } catch (e) {
      _error = 'Error loading complaints: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createComplaint({
    required String category,
    required String description,
    required LocationData location,
    required String village,
    String? ward,
    String? imageBase64,
  }) async {
    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        // Save offline
        await _saveComplaintOffline(
          category: category,
          description: description,
          location: location,
          village: village,
          ward: ward,
          imageBase64: imageBase64,
        );
        return true;
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _complaintService.createComplaint(
        category: category,
        description: description,
        location: location,
        village: village,
        ward: ward,
        imageBase64: imageBase64,
      );

      if (result['success'] == true) {
        final newComplaint = ComplaintModel.fromJson(result['complaint']);
        _complaints.insert(0, newComplaint);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to create complaint';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Save offline if API call fails
      await _saveComplaintOffline(
        category: category,
        description: description,
        location: location,
        village: village,
        ward: ward,
        imageBase64: imageBase64,
      );
      _error = 'Saved offline due to connectivity issues';
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> _saveComplaintOffline({
    required String category,
    required String description,
    required LocationData location,
    required String village,
    String? ward,
    String? imageBase64,
  }) async {
    final offlineComplaint = ComplaintModel(
      id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
      complaintId: 'OFFLINE_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'current_user',
      category: category,
      description: description,
      location: location,
      village: village,
      ward: ward,
      createdAt: DateTime.now(),
    );

    await _offlineService.saveComplaint(offlineComplaint, imageBase64);
    _offlineComplaints.add(offlineComplaint);
    notifyListeners();
  }

  Future<void> loadOfflineComplaints() async {
    try {
      _offlineComplaints = await _offlineService.getOfflineComplaints();
      notifyListeners();
    } catch (e) {
      _error = 'Error loading offline complaints: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> syncOfflineComplaints() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        return; // No connectivity
      }

      final offlineComplaints = await _offlineService.getOfflineComplaints();

      for (final complaint in offlineComplaints) {
        try {
          final result = await _complaintService.createComplaint(
            category: complaint.category,
            description: complaint.description,
            location: complaint.location,
            village: complaint.village,
            ward: complaint.ward,
          );

          if (result['success'] == true) {
            // Remove from offline storage
            await _offlineService.removeComplaint(complaint.id);
            _offlineComplaints.removeWhere((c) => c.id == complaint.id);
          }
        } catch (e) {
          // Continue with other complaints if one fails
          continue;
        }
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error syncing offline complaints: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> sendReminder(String complaintId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _complaintService.sendReminder(complaintId);

      if (result['success'] == true) {
        // Update the complaint in the list
        final index = _complaints.indexWhere((c) => c.id == complaintId);
        if (index != -1) {
          _complaints[index] = _complaints[index].copyWith(reminderSent: true);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to send reminder';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error sending reminder: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addFeedback(String complaintId, String feedback, int rating) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _complaintService.addFeedback(
        complaintId: complaintId,
        feedback: feedback,
        rating: rating,
      );

      if (result['success'] == true) {
        // Update the complaint in the list
        final index = _complaints.indexWhere((c) => c.id == complaintId);
        if (index != -1) {
          _complaints[index] = _complaints[index].copyWith(
            feedback: feedback,
            rating: rating,
          );
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to add feedback';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error adding feedback: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<ComplaintModel> getComplaintsByStatus(String status) {
    return _complaints.where((complaint) => complaint.status == status).toList();
  }

  List<ComplaintModel> getComplaintsByCategory(String category) {
    return _complaints.where((complaint) => complaint.category == category).toList();
  }

  ComplaintModel? getComplaintById(String id) {
    try {
      return _complaints.firstWhere((complaint) => complaint.id == id);
    } catch (e) {
      return null;
    }
  }

  int get totalComplaints => _complaints.length + _offlineComplaints.length;
  int get pendingComplaints => _complaints.where((c) => c.status == 'PENDING').length;
  int get inProgressComplaints => _complaints.where((c) => c.status == 'IN_PROGRESS').length;
  int get resolvedComplaints => _complaints.where((c) => c.status == 'RESOLVED').length;
}