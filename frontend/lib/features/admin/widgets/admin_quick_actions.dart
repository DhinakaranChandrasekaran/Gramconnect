import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminQuickActions extends StatelessWidget {
  const AdminQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildActionButton(
                  context,
                  'Manage Complaints',
                  Icons.assignment_outlined,
                  AppTheme.primaryColor,
                      () => Navigator.pushNamed(context, '/admin-complaints'),
                ),
                _buildActionButton(
                  context,
                  'Garbage Schedules',
                  Icons.schedule_outlined,
                  AppTheme.secondaryColor,
                      () => Navigator.pushNamed(context, '/admin-schedules'),
                ),
                _buildActionButton(
                  context,
                  'User Management',
                  Icons.people_outline,
                  AppTheme.accentColor,
                      () => Navigator.pushNamed(context, '/admin-users'),
                ),
                _buildActionButton(
                  context,
                  'Send Notification',
                  Icons.notifications_outlined,
                  AppTheme.warningColor,
                      () => Navigator.pushNamed(context, '/admin-notifications'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}