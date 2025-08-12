import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/complaint_provider.dart';
import '../../../core/models/complaint_model.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/complaint_status_timeline.dart';
import '../widgets/feedback_dialog.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintDetailScreen({
    super.key,
    required this.complaintId,
  });

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  ComplaintModel? complaint;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaint();
  }

  void _loadComplaint() {
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    complaint = complaintProvider.getComplaintById(widget.complaintId);

    if (complaint == null) {
      // Try to find in offline complaints
      final offlineComplaints = complaintProvider.offlineComplaints
          .where((c) => c.id == widget.complaintId);
      if (offlineComplaints.isNotEmpty) {
        complaint = offlineComplaints.first;
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _sendReminder() async {
    if (complaint == null) return;

    try {
      final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
      final success = await complaintProvider.sendReminder(complaint!.id);

      if (success) {
        _showSuccessSnackBar('Reminder sent successfully');
        _loadComplaint(); // Refresh complaint data
      } else {
        _showErrorSnackBar(complaintProvider.error ?? 'Failed to send reminder');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _showFeedbackDialog() async {
    if (complaint == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FeedbackDialog(complaint: complaint!),
    );

    if (result != null) {
      try {
        final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
        final success = await complaintProvider.addFeedback(
          complaint!.id,
          result['feedback'],
          result['rating'],
        );

        if (success) {
          _showSuccessSnackBar('Feedback submitted successfully');
          _loadComplaint(); // Refresh complaint data
        } else {
          _showErrorSnackBar(complaintProvider.error ?? 'Failed to submit feedback');
        }
      } catch (e) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (complaint == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body: const Center(
          child: Text('Complaint not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint ${complaint!.complaintId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Details Card
            _buildDetailsCard(),

            const SizedBox(height: 16),

            // Image (if available)
            if (complaint!.imageUrl != null) ...[
              _buildImageCard(),
              const SizedBox(height: 16),
            ],

            // Location Card
            _buildLocationCard(),

            const SizedBox(height: 16),

            // Timeline
            ComplaintStatusTimeline(complaint: complaint!),

            const SizedBox(height: 16),

            // Admin Response (if available)
            if (complaint!.adminResponse != null) ...[
              _buildAdminResponseCard(),
              const SizedBox(height: 16),
            ],

            // Feedback (if available)
            if (complaint!.feedback != null) ...[
              _buildFeedbackCard(),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.getStatusColor(complaint!.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getStatusIcon(complaint!.status),
                color: AppColors.getStatusColor(complaint!.status),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint!.statusDisplayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getStatusColor(complaint!.status),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Submitted on ${_formatDate(complaint!.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.getCategoryColor(complaint!.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    complaint!.categoryDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getCategoryColor(complaint!.category),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  complaint!.complaintId,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              complaint!.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attached Image',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                complaint!.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${complaint!.village}${complaint!.ward != null ? ', Ward ${complaint!.ward}' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lat: ${complaint!.location.latitude.toStringAsFixed(6)}, '
                            'Lng: ${complaint!.location.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminResponseCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Response',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              complaint!.adminResponse!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Feedback',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < (complaint!.rating ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${complaint!.rating}/5',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (complaint!.feedback != null) ...[
              const SizedBox(height: 8),
              Text(
                complaint!.feedback!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final canSendReminder = complaint!.status == 'PENDING' &&
        !complaint!.reminderSent &&
        DateTime.now().difference(complaint!.createdAt).inHours >= 24;

    final canGiveFeedback = complaint!.status == 'RESOLVED' &&
        complaint!.feedback == null;

    if (!canSendReminder && !canGiveFeedback) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canSendReminder) ...[
          ElevatedButton.icon(
            onPressed: _sendReminder,
            icon: const Icon(Icons.notifications),
            label: const Text('Send Reminder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (canGiveFeedback) ...[
          ElevatedButton.icon(
            onPressed: _showFeedbackDialog,
            icon: const Icon(Icons.feedback),
            label: const Text('Give Feedback'),
          ),
        ],
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.pending;
      case 'IN_PROGRESS':
        return Icons.work;
      case 'RESOLVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}