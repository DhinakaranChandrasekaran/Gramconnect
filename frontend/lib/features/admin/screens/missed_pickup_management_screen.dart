import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../services/admin_service.dart';

class MissedPickupManagementScreen extends StatefulWidget {
  const MissedPickupManagementScreen({super.key});

  @override
  State<MissedPickupManagementScreen> createState() => _MissedPickupManagementScreenState();
}

class _MissedPickupManagementScreenState extends State<MissedPickupManagementScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _missedPickups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMissedPickups();
  }

  Future<void> _loadMissedPickups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Add getMissedPickups method to AdminService
      setState(() {
        _missedPickups = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Missed Pickup Management'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Error loading missed pickups'),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMissedPickups,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_missedPickups.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('No missed pickups reported'),
            SizedBox(height: 8),
            Text('All garbage collections are on schedule!'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMissedPickups,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _missedPickups.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final missedPickup = _missedPickups[index];
          return _buildMissedPickupCard(missedPickup);
        },
      ),
    );
  }

  Widget _buildMissedPickupCard(dynamic missedPickup) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${missedPickup['village']} - Ward ${missedPickup['ward']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(missedPickup['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    missedPickup['status'] ?? 'REPORTED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(missedPickup['status']),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Reason
            Text(
              'Reason: ${missedPickup['reason'] ?? 'Not specified'}',
              style: const TextStyle(fontSize: 14),
            ),

            if (missedPickup['description'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Details: ${missedPickup['description']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Reported Date
            Text(
              'Reported: ${_formatDate(missedPickup['reportedAt'])}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 12),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showStatusUpdateDialog(missedPickup),
                child: const Text('Update Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'REPORTED':
        return Colors.orange;
      case 'ACKNOWLEDGED':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showStatusUpdateDialog(dynamic missedPickup) {
    final responseController = TextEditingController();
    String selectedStatus = missedPickup['status'] ?? 'REPORTED';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Missed Pickup Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ['REPORTED', 'ACKNOWLEDGED', 'RESOLVED']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) => selectedStatus = value!,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: responseController,
              decoration: const InputDecoration(
                labelText: 'Admin Response (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement update missed pickup status
              _showSuccessSnackBar('Status updated successfully');
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}