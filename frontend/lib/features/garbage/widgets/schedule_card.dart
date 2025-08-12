import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/garbage_schedule_model.dart';

class ScheduleCard extends StatelessWidget {
  final GarbageScheduleModel schedule;
  final VoidCallback onReportMissedPickup;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.onReportMissedPickup,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(context),

              const SizedBox(height: 20),

              // Collection Days Section
              _buildCollectionDays(context),

              // Description Section
              if (schedule.description != null && schedule.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDescription(context),
              ],

              const SizedBox(height: 20),

              // Action Button
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Icon Container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 24,
          ),
        ),

        const SizedBox(width: 16),

        // Area and Time Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.displayArea,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pickup: ${schedule.pickupTime}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Next Collection Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getNextCollectionColor(),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getNextCollectionColor().withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            schedule.nextCollectionDay,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionDays(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              'Collection Days',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: schedule.collectionDays.map((day) {
            final isToday = _isToday(day);
            final isUpcoming = _isUpcoming(day);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isToday
                    ? AppTheme.primaryColor
                    : isUpcoming
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday
                      ? AppTheme.primaryColor
                      : isUpcoming
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isToday || isUpcoming
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: isToday
                      ? Colors.white
                      : isUpcoming
                      ? AppTheme.primaryColor
                      : Colors.grey[700],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blue.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onReportMissedPickup,
        icon: const Icon(Icons.report_problem, size: 18),
        label: const Text('Report Missed Pickup'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange[600],
          side: BorderSide(color: Colors.orange[600]!, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Color _getNextCollectionColor() {
    switch (schedule.nextCollectionDay) {
      case 'Today':
        return Colors.green[600]!;
      case 'Tomorrow':
        return Colors.orange[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final currentDay = _getDayName(now.weekday);
    return day == currentDay;
  }

  bool _isUpcoming(String day) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowDay = _getDayName(tomorrow.weekday);
    return day == tomorrowDay;
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }
}