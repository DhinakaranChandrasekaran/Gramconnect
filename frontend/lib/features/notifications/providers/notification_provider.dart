import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/env.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService;

  NotificationProvider(this._apiService);

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // Fetch notifications
  Future<void> fetchNotifications() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get(Environment.notificationsEndpoint);

      if (response.isSuccess) {
        _notifications = List<Map<String, dynamic>>.from(response.data);
        _updateUnreadCount();
      } else {
        _setError(response.error ?? 'Failed to fetch notifications');
      }
    } catch (e) {
      _setError('An unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.patch(
        '${Environment.notificationsEndpoint}/$notificationId/read',
        {},
      );

      if (response.isSuccess) {
        // Update local state
        final index = _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['read'] = true;
          _updateUnreadCount();
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final unreadNotifications = _notifications.where((n) => !n['read']).toList();
    
    for (final notification in unreadNotifications) {
      await markAsRead(notification['id']);
    }
  }

  // Send notification (admin functionality)
  Future<bool> sendNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'INFO',
    Map<String, dynamic>? meta,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        '${Environment.notificationsEndpoint}/send',
        {
          'userId': userId,
          'title': title,
          'body': body,
          'type': type,
          if (meta != null) 'meta': meta,
        },
      );

      if (response.isSuccess) {
        return true;
      } else {
        _setError(response.error ?? 'Failed to send notification');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n['read']).length;
  }

  // Get notification icon
  IconData getNotificationIcon(String type) {
    switch (type.toUpperCase()) {
      case 'COMPLAINT_UPDATE':
        return Icons.update;
      case 'REMINDER':
        return Icons.notification_important;
      case 'SCHEDULE_UPDATE':
        return Icons.schedule;
      case 'ADMIN_MESSAGE':
        return Icons.admin_panel_settings;
      case 'INFO':
      default:
        return Icons.info_outline;
    }
  }

  // Get notification color
  Color getNotificationColor(String type) {
    switch (type.toUpperCase()) {
      case 'COMPLAINT_UPDATE':
        return Colors.blue;
      case 'REMINDER':
        return Colors.orange;
      case 'SCHEDULE_UPDATE':
        return Colors.green;
      case 'ADMIN_MESSAGE':
        return Colors.purple;
      case 'INFO':
      default:
        return Colors.grey;
    }
  }

  // Get relative time string
  String getRelativeTime(String createdAt) {
    try {
      final DateTime createdDate = DateTime.parse(createdAt);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(createdDate);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return _formatDate(createdDate);
      }
    } catch (e) {
      return 'Unknown';
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