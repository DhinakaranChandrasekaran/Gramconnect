import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final List<String> _notifications = [];
  bool _hasUnread = false;

  List<String> get notifications => _notifications;
  bool get hasUnread => _hasUnread;

  void addNotification(String message) {
    _notifications.insert(0, message); // latest first
    _hasUnread = true;
    notifyListeners();
  }

  void markAllAsRead() {
    _hasUnread = false;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _hasUnread = false;
    notifyListeners();
  }
}
