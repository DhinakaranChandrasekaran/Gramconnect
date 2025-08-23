import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/complaint_provider.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).fetchUserComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, child) {
          if (complaintProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (complaintProvider.complaints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.report_problem_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No complaints yet',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first complaint',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => complaintProvider.fetchUserComplaints(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: complaintProvider.complaints.length,
              itemBuilder: (context, index) {
                final complaint = complaintProvider.complaints[index];
                return _buildComplaintCard(context, complaint, complaintProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new-complaint');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, Map<String, dynamic> complaint, ComplaintProvider provider) {
    final status = complaint['status'] as String;
    final category = complaint['category'] as String;
    final createdAt = DateTime.parse(complaint['createdAt']);
    final daysDiff = DateTime.now().difference(createdAt).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/complaint-details', arguments: complaint['id']);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          style: AppTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${complaint['village']}, ${complaint['ward']}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
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
              
              const SizedBox(height: 12),
              
              Text(
                complaint['description'],
                style: AppTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    daysDiff == 0 ? 'Today' : '$daysDiff days ago',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  if (status != 'RESOLVED')
                    TextButton.icon(
                      onPressed: () async {
                        final canRemind = await provider.canSendReminder(complaint['id']);
                        if (canRemind && context.mounted) {
                          _showReminderDialog(context, complaint['id'], provider);
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cannot send reminder at this time')),
                          );
                        }
                      },
                      icon: const Icon(Icons.notification_important, size: 16),
                      label: const Text('Remind', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context, String complaintId, ComplaintProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Reminder'),
        content: const Text('Send a reminder to administrators about this complaint?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.sendReminder(complaintId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder sent successfully!')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}