import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../garbage/models/garbage_schedule_model.dart';
import '../../garbage/services/garbage_schedule_service.dart';
import 'schedule_card.dart';
import 'missed_pickup_dialog.dart';
import 'package:go_router/go_router.dart';

class GarbageScheduleSection extends StatelessWidget {
  const GarbageScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return const SizedBox();

    return FutureBuilder<List<GarbageScheduleModel>>(
      future: GarbageScheduleService()
          .getSchedulesByVillageAndWard(user.village, user.ward),
      builder: (context, snapshot) {
        final hasError = snapshot.hasError;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final schedules = (!hasError && snapshot.data != null)
            ? snapshot.data!
            : <GarbageScheduleModel>[];

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card - Garbage Scheduler Access
              _buildHeaderCard(context),

              const SizedBox(height: 24),

              // Garbage Schedule Section
              _buildGarbageScheduleSection(context, isLoading, schedules),

              const SizedBox(height: 32),

              // Missed Pickup Section
              _buildMissedPickupSection(context, schedules),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => context.push('/garbage-schedule'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Garbage Scheduler',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View full schedule and manage pickups',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGarbageScheduleSection(BuildContext context, bool isLoading, List<GarbageScheduleModel> schedules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Upcoming Collections',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Content
        if (isLoading)
          _buildLoadingCard()
        else if (schedules.isNotEmpty)
          Column(
            children: schedules.map((schedule) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ScheduleCard(
                  schedule: schedule,
                  onReportMissedPickup: () {
                    showDialog(
                      context: context,
                      builder: (_) => MissedPickupDialog(schedule: schedule),
                    );
                  },
                ),
              );
            }).toList(),
          )
        else
          _buildEmptyStateCard(),
      ],
    );
  }

  Widget _buildMissedPickupSection(BuildContext context, List<GarbageScheduleModel> schedules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.report_problem,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Missed a Pickup?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          'Report any missed garbage collections to help improve our service',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 16),

        // Action Button Card
        Container(
          width: double.infinity,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: schedules.isNotEmpty
                        ? () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            MissedPickupDialog(schedule: schedules.first),
                      );
                    }
                        : null,
                    icon: const Icon(Icons.report),
                    label: const Text('Report Missed Pickup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: schedules.isNotEmpty
                          ? Colors.orange[600]
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  if (schedules.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'No active schedules available',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading schedules...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.calendar_today,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                "No schedule available",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Collection schedules will appear here",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}