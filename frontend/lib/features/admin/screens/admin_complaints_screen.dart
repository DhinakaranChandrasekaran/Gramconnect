import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Complaints'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComplaintsList('PENDING'),
          _buildComplaintsList('IN_PROGRESS'),
          _buildComplaintsList('RESOLVED'),
        ],
      ),
    );
  }

  Widget _buildComplaintsList(String status) {
    // Mock data - replace with actual API call
    final complaints = _getMockComplaints(status);

    if (complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${status.toLowerCase().replaceAll('_', ' ')} complaints',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return _buildComplaintCard(complaint);
      },
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final status = complaint['status'] as String;
    final category = complaint['category'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    color: AppColors.getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: AppColors.getStatusColor(status),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryDisplayName(category),
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

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.getStatusColor(status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: AppColors.getStatusColor(status),
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
                  complaint['createdAt'],
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),

                const Spacer(),

                if (status != 'RESOLVED')
                  ElevatedButton(
                    onPressed: () => _showStatusUpdateDialog(complaint),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Update Status',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(Map<String, dynamic> complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Complaint Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('In Progress'),
              leading: Radio<String>(
                value: 'IN_PROGRESS',
                groupValue: complaint['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateComplaintStatus(complaint['id'], 'IN_PROGRESS');
                },
              ),
            ),
            ListTile(
              title: const Text('Resolved'),
              leading: Radio<String>(
                value: 'RESOLVED',
                groupValue: complaint['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateComplaintStatus(complaint['id'], 'RESOLVED');
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _updateComplaintStatus(String complaintId, String newStatus) {
    // TODO: Implement API call to update complaint status
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Complaint status updated to ${_getStatusText(newStatus)}'),
        backgroundColor: AppTheme.successColor,
      ),
    );

    // Refresh the list
    setState(() {});
  }

  List<Map<String, dynamic>> _getMockComplaints(String status) {
    // Mock data - replace with actual API call
    final allComplaints = [
      {
        'id': '1',
        'category': 'GARBAGE',
        'description': 'Garbage not collected for 3 days in our area',
        'village': 'Perungalathur',
        'ward': 'Ward 1',
        'status': 'PENDING',
        'createdAt': '2 days ago',
      },
      {
        'id': '2',
        'category': 'WATER',
        'description': 'Water supply disrupted since morning',
        'village': 'Tambaram',
        'ward': 'Ward 2',
        'status': 'IN_PROGRESS',
        'createdAt': '1 day ago',
      },
      {
        'id': '3',
        'category': 'ELECTRICITY',
        'description': 'Street lights not working',
        'village': 'Chromepet',
        'ward': 'Ward 3',
        'status': 'RESOLVED',
        'createdAt': '5 days ago',
      },
    ];

    return allComplaints.where((c) => c['status'] == status).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'GARBAGE':
        return Icons.delete_outline;
      case 'WATER':
        return Icons.water_drop_outlined;
      case 'ELECTRICITY':
        return Icons.electrical_services_outlined;
      case 'DRAINAGE':
        return Icons.settings_input_component_outlined;
      case 'ROAD_DAMAGE':
        return Icons.construction_outlined;
      case 'HEALTH':
        return Icons.local_hospital_outlined;
      case 'TRANSPORT':
        return Icons.directions_bus_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toUpperCase()) {
      case 'GARBAGE':
        return 'Garbage Collection';
      case 'WATER':
        return 'Water Supply';
      case 'ELECTRICITY':
        return 'Electricity';
      case 'DRAINAGE':
        return 'Drainage';
      case 'ROAD_DAMAGE':
        return 'Road Damage';
      case 'HEALTH':
        return 'Health Services';
      case 'TRANSPORT':
        return 'Transportation';
      default:
        return category.replaceAll('_', ' ');
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'RESOLVED':
        return 'Resolved';
      default:
        return status;
    }
  }
}