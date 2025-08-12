import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../services/admin_service.dart';

class ComplaintManagementScreen extends StatefulWidget {
  const ComplaintManagementScreen({super.key});

  @override
  State<ComplaintManagementScreen> createState() => _ComplaintManagementScreenState();
}

class _ComplaintManagementScreenState extends State<ComplaintManagementScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _complaints = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final complaints = await _adminService.getAllComplaints();
      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateComplaintStatus(String complaintId, String status, String? response) async {
    try {
      await _adminService.updateComplaintStatus(complaintId, status, response);
      _showSuccessSnackBar('Complaint status updated successfully');
      _loadComplaints();
    } catch (e) {
      _showErrorSnackBar('Failed to update status: ${e.toString()}');
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

  List<dynamic> _getFilteredComplaints() {
    if (_selectedFilter == 'ALL') {
      return _complaints;
    }
    return _complaints.where((c) => c['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Management'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // Complaints List
          Expanded(
            child: _buildComplaintsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('ALL', 'All'),
            _buildFilterChip('PENDING', 'Pending'),
            _buildFilterChip('IN_PROGRESS', 'In Progress'),
            _buildFilterChip('RESOLVED', 'Resolved'),
            _buildFilterChip('REJECTED', 'Rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
        selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildComplaintsList() {
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
            Text('Error loading complaints'),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadComplaints,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredComplaints = _getFilteredComplaints();

    if (filteredComplaints.isEmpty) {
      return const Center(
        child: Text('No complaints found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredComplaints.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final complaint = filteredComplaints[index];
          return _buildComplaintCard(complaint);
        },
      ),
    );
  }

  Widget _buildComplaintCard(dynamic complaint) {
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
                  complaint['complaintId'] ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(complaint['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    complaint['status'] ?? 'PENDING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(complaint['status']),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(complaint['category']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                complaint['category'] ?? 'OTHER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getCategoryColor(complaint['category']),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              complaint['description'] ?? '',
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  complaint['village'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showStatusUpdateDialog(complaint),
                    child: const Text('Update Status'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showComplaintDetails(complaint),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'GARBAGE':
        return Colors.red;
      case 'WATER_SUPPLY':
        return Colors.blue;
      case 'ELECTRICITY':
        return Colors.yellow[700]!;
      case 'DRAINAGE':
        return Colors.grey;
      case 'ROAD_DAMAGE':
        return Colors.orange;
      case 'HEALTH_CENTER':
        return Colors.purple;
      case 'TRANSPORT':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _showStatusUpdateDialog(dynamic complaint) {
    final statusController = TextEditingController();
    final responseController = TextEditingController();
    String selectedStatus = complaint['status'] ?? 'PENDING';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Complaint Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ['PENDING', 'IN_PROGRESS', 'RESOLVED', 'REJECTED']
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
              _updateComplaintStatus(
                complaint['id'],
                selectedStatus,
                responseController.text.trim().isEmpty ? null : responseController.text.trim(),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showComplaintDetails(dynamic complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complaint Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', complaint['complaintId'] ?? 'N/A'),
              _buildDetailRow('Category', complaint['category'] ?? 'N/A'),
              _buildDetailRow('Status', complaint['status'] ?? 'N/A'),
              _buildDetailRow('Village', complaint['village'] ?? 'N/A'),
              _buildDetailRow('Description', complaint['description'] ?? 'N/A'),
              if (complaint['adminResponse'] != null)
                _buildDetailRow('Admin Response', complaint['adminResponse']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}