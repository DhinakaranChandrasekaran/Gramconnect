import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../complaints/providers/complaint_provider.dart';

class RecentComplaints extends StatelessWidget {
  const RecentComplaints({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, complaintProvider, child) {
        if (complaintProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (complaintProvider.complaints.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.report_problem_outlined,
                    size: 48,
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
                      Navigator.pushNamed(context, '/new-complaint');
                    },
                    child: const Text('Create First Complaint'),
                  ),
                ],
              ),
            ),
          );
        }

        final recentComplaints = complaintProvider.complaints.take(3).toList();

        return Column(
          children: [
            ...recentComplaints.map((complaint) => _buildComplaintCard(context, complaint, complaintProvider)),
            
            const SizedBox(height: 8),
            
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
        );
      },
    );
  }

  Widget _buildComplaintCard(BuildContext context, Map<String, dynamic> complaint, ComplaintProvider provider) {
    final status = complaint['status'] as String;
    final category = complaint['category'] as String;
    final createdAt = DateTime.parse(complaint['createdAt']);
    final daysDiff = DateTime.now().difference(createdAt).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/complaint-details', arguments: complaint['id']);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: provider.getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  provider.getCategoryIcon(category),
                  color: provider.getStatusColor(status),
                  size: 20,
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
                    const SizedBox(height: 4),
                    Text(
                      complaint['description'],
                      style: AppTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
        ),
      ),
    );
  }
}