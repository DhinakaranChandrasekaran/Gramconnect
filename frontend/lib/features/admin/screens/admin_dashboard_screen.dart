import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_stats_cards.dart';
import '../widgets/admin_quick_actions.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  void _loadAdminData() async {
    // TODO: Load admin-specific data
    // - Total complaints in region
    // - Pending complaints
    // - Garbage schedules
    // - Missed pickups
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadAdminData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with green background
                const AdminHeader(),

                const SizedBox(height: 16),

                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards
                      const AdminStatsCards(),

                      const SizedBox(height: 16),

                      // Quick Actions
                      const AdminQuickActions(),

                      const SizedBox(height: 16),

                      // Recent Activity Section
                      _buildRecentActivitySection(),

                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Activity Items
            _buildActivityItem(
              'New complaint submitted',
              'Garbage collection issue in Ward 3',
              '2 minutes ago',
              Icons.report_problem_outlined,
              AppTheme.warningColor,
            ),

            _buildActivityItem(
              'Complaint resolved',
              'Water supply issue marked as resolved',
              '1 hour ago',
              Icons.check_circle_outline,
              AppTheme.successColor,
            ),

            _buildActivityItem(
              'Missed pickup reported',
              'Garbage not collected in Ward 1',
              '3 hours ago',
              Icons.delete_outline,
              AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String title,
      String description,
      String time,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}