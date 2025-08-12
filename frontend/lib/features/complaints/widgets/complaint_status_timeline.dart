import 'package:flutter/material.dart';
import '../../../core/models/complaint_model.dart';
import '../../../core/theme/app_theme.dart';

class ComplaintStatusTimeline extends StatelessWidget {
  final ComplaintModel complaint;

  const ComplaintStatusTimeline({
    super.key,
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Timeline',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Complaint Submitted',
              complaint.createdAt,
              true,
              Icons.assignment,
              AppTheme.primaryColor,
            ),
            if (complaint.status == 'IN_PROGRESS' || complaint.status == 'RESOLVED') ...[
              _buildTimelineItem(
                'In Progress',
                complaint.updatedAt ?? complaint.createdAt,
                true,
                Icons.work,
                Colors.blue,
              ),
            ],
            if (complaint.status == 'RESOLVED') ...[
              _buildTimelineItem(
                'Resolved',
                complaint.resolvedAt ?? complaint.updatedAt ?? complaint.createdAt,
                true,
                Icons.check_circle,
                AppTheme.successColor,
              ),
            ],
            if (complaint.status == 'REJECTED') ...[
              _buildTimelineItem(
                'Rejected',
                complaint.updatedAt ?? complaint.createdAt,
                true,
                Icons.cancel,
                AppTheme.errorColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
      String title,
      DateTime date,
      bool isCompleted,
      IconData icon,
      Color color,
      ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? color : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDateTime(date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}