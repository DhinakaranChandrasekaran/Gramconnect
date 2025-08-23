import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../auth/providers/auth_provider.dart';
import '../complaints/providers/complaint_provider.dart';
import '../garbage/providers/garbage_provider.dart';
import '../notifications/providers/notification_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/quick_actions.dart';
import 'widgets/garbage_schedule_card.dart';
import 'widgets/recent_complaints.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    final garbageProvider = Provider.of<GarbageProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    // Load user data
    await Future.wait([
      complaintProvider.fetchUserComplaints(),
      garbageProvider.fetchSchedules(),
      notificationProvider.fetchNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with user info and notifications
                const HomeHeader(),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                const QuickActions(),
                
                const SizedBox(height: 24),
                
                // Garbage Schedule Section
                const Text(
                  'Garbage Collection',
                  style: AppTheme.titleLarge,
                ),
                
                const SizedBox(height: 12),
                
                const GarbageScheduleCard(),
                
                const SizedBox(height: 24),
                
                // Recent Complaints Section
                const Text(
                  'Recent Complaints',
                  style: AppTheme.titleLarge,
                ),
                
                const SizedBox(height: 12),
                
                const RecentComplaints(),
                
                const SizedBox(height: 80), // Bottom padding for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to new complaint screen
          Navigator.pushNamed(context, '/new-complaint');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
      ),
    );
  }
}