import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../garbage/providers/garbage_provider.dart';

class GarbageSection extends StatelessWidget {
  const GarbageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GarbageProvider>(
      builder: (context, garbageProvider, child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.75, // 3/4 width
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
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
                      'Garbage Collection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (garbageProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (garbageProvider.schedules.isEmpty)
                    _buildNoScheduleCard()
                  else
                    _buildScheduleCard(context, garbageProvider.schedules.first, garbageProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No schedule available',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, Map<String, dynamic> schedule, GarbageProvider provider) {
    final nextPickup = provider.getNextPickup(schedule);
    final isToday = provider.isPickupToday(schedule);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday
            ? AppTheme.successColor.withOpacity(0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday
              ? AppTheme.successColor.withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: isToday ? AppTheme.successColor : AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Pickup',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      provider.getPickupStatusText(schedule),
                      style: AppTheme.titleSmall.copyWith(
                        color: isToday ? AppTheme.successColor : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
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
                'Time: ${schedule['time']}',
                style: AppTheme.bodySmall,
              ),

              const SizedBox(width: 16),

              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                'Days: ${(schedule['days'] as List).join(', ')}',
                style: AppTheme.bodySmall,
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/missed-pickup');
              },
              icon: const Icon(Icons.report_problem_outlined, size: 16),
              label: const Text('Report Missed Pickup'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.warningColor,
                side: const BorderSide(color: AppTheme.warningColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}