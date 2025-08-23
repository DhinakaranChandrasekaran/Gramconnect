import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../garbage/providers/garbage_provider.dart';

class GarbageScheduleCard extends StatelessWidget {
  const GarbageScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GarbageProvider>(
      builder: (context, garbageProvider, child) {
        if (garbageProvider.isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (garbageProvider.schedules.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No garbage collection schedules',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final schedule = garbageProvider.schedules.first;
        final nextPickup = garbageProvider.getNextPickup(schedule);
        final isToday = garbageProvider.isPickupToday(schedule);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isToday 
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: isToday ? AppTheme.successColor : AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Pickup',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            garbageProvider.getPickupStatusText(schedule),
                            style: AppTheme.titleMedium.copyWith(
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
                      Icons.schedule,
                      size: 16,
                      color: AppTheme.textSecondary,
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
                      color: AppTheme.textSecondary,
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}