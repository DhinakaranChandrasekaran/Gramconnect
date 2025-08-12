import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<NotificationProvider>(context);
    final notifications = notifier.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              notifier.clearNotifications();
            },
            tooltip: 'Clear All',
          )
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
        child: Text(
          'No notifications yet.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final message = notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(message),
          );
        },
      ),
    );
  }
}
