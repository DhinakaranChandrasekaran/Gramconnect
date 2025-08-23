import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/garbage_provider.dart';

class GarbageScreen extends StatefulWidget {
  const GarbageScreen({super.key});

  @override
  State<GarbageScreen> createState() => _GarbageScreenState();
}

class _GarbageScreenState extends State<GarbageScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final garbageProvider = Provider.of<GarbageProvider>(context, listen: false);
      garbageProvider.fetchSchedules();
      garbageProvider.fetchMyMissedPickups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garbage Collection'),
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Schedules'),
            Tab(text: 'Missed Pickups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSchedulesTab(),
          _buildMissedPickupsTab(),
        ],
      ),
    );
  }

  Widget _buildSchedulesTab() {
    return Consumer<GarbageProvider>(
      builder: (context, garbageProvider, child) {
        if (garbageProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (garbageProvider.schedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No schedules available',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Contact your local administrator to set up garbage collection schedules',
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
          onRefresh: () => garbageProvider.fetchSchedules(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: garbageProvider.schedules.length,
            itemBuilder: (context, index) {
              final schedule = garbageProvider.schedules[index];
              return _buildScheduleCard(context, schedule, garbageProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildMissedPickupsTab() {
    return Consumer<GarbageProvider>(
      builder: (context, garbageProvider, child) {
        if (garbageProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (garbageProvider.missedPickups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No missed pickups reported',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Great! All garbage collections are on schedule',
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
          onRefresh: () => garbageProvider.fetchMyMissedPickups(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: garbageProvider.missedPickups.length,
            itemBuilder: (context, index) {
              final missedPickup = garbageProvider.missedPickups[index];
              return _buildMissedPickupCard(context, missedPickup, garbageProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildScheduleCard(BuildContext context, Map<String, dynamic> schedule, GarbageProvider provider) {
    final nextPickup = provider.getNextPickup(schedule);
    final isToday = provider.isPickupToday(schedule);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        '${schedule['village']}, Ward ${schedule['ward']}',
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.getPickupStatusText(schedule),
                        style: AppTheme.bodyMedium.copyWith(
                          color: isToday ? AppTheme.successColor : AppTheme.textSecondary,
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
                  _showMissedPickupDialog(context, schedule['id'], schedule['village']);
                },
                icon: const Icon(Icons.report_problem_outlined, size: 16),
                label: const Text('Report Missed Pickup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissedPickupCard(BuildContext context, Map<String, dynamic> missedPickup, GarbageProvider provider) {
    final status = missedPickup['status'] as String;
    final timestamp = DateTime.parse(missedPickup['timestamp']);
    final daysDiff = DateTime.now().difference(timestamp).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: provider.getMissedPickupStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.report_problem_outlined,
                    color: provider.getMissedPickupStatusColor(status),
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Missed Pickup Report',
                        style: AppTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        missedPickup['village'],
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: provider.getMissedPickupStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: provider.getMissedPickupStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    provider.getMissedPickupStatusText(status),
                    style: TextStyle(
                      color: provider.getMissedPickupStatusColor(status),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            if (missedPickup['note'] != null && missedPickup['note'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                missedPickup['note'],
                style: AppTheme.bodyMedium,
              ),
            ],
            
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMissedPickupDialog(BuildContext context, String scheduleId, String village) {
    final noteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Missed Pickup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Report a missed garbage pickup for $village?'),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'Describe the issue...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<GarbageProvider>(
            builder: (context, garbageProvider, child) => ElevatedButton(
              onPressed: garbageProvider.isLoading 
                ? null 
                : () async {
                    final success = await garbageProvider.reportMissedPickup(
                      scheduleId: scheduleId,
                      village: village,
                      note: noteController.text.trim(),
                    );
                    
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Missed pickup reported successfully!')),
                      );
                    }
                  },
              child: garbageProvider.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Report'),
            ),
          ),
        ],
      ),
    );
  }
}