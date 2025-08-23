import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../complaints/providers/complaint_provider.dart';

class RecentComplaintsSection extends StatelessWidget {
  const RecentComplaintsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, complaintProvider, child) {
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
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Recent Complaints',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                if (complaintProvider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (complaintProvider.complaints.isEmpty)
                  _buildNoComplaintsCard(context)
                else
                  _buildComplaintsList(context, complaintProvider),

                const SizedBox(height: 12),

                // View All Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/complaints');
                    },
                    child: const Text('View All Complaints'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoComplaintsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.report_problem_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No complaints yet',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/complaint-form');
            },
            child: const Text('Create First Complaint'),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList(BuildContext context, ComplaintProvider provider) {
    final recentComplaints = provider.complaints.take(3).toList();

    return Column(
      children: recentComplaints.map((complaint) {
        return _buildComplaintCard(context, complaint, provider);
      }).toList(),
    );
  }

  Widget _buildComplaintCard(BuildContext context, Map<String, dynamic> complaint, ComplaintProvider provider) {
    final status = complaint['status'] as String;
    final category = complaint['category'] as String;
    final createdAt = DateTime.parse(complaint['createdAt']);
    final daysDiff = DateTime.now().difference(createdAt).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: provider.getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              provider.getCategoryIcon(category),
              color: provider.getStatusColor(status),
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // Complaint Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.getCategoryDisplayName(category),
                  style: AppTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  complaint['description'],
                  style: AppTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  daysDiff == 0 ? 'Today' : '$daysDiff days ago',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: provider.getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: provider.getStatusColor(status).withOpacity(0.3),
              ),
            ),
            child: Text(
              provider.getStatusText(status),
              style: TextStyle(
                color: provider.getStatusColor(status),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}