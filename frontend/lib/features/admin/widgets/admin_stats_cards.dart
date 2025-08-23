import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminStatsCards extends StatelessWidget {
  const AdminStatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Complaints',
                '45',
                Icons.report_problem_outlined,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Pending',
                '12',
                Icons.pending_actions,
                AppTheme.warningColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Second Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Resolved',
                '28',
                Icons.check_circle_outline,
                AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Missed Pickups',
                '5',
                Icons.delete_outline,
                AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title,
      String count,
      IconData icon,
      Color color,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}