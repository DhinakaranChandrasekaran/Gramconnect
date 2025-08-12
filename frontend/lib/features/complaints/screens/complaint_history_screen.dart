import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/complaint_provider.dart';
import '../../../core/models/complaint_model.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/complaint_card.dart';
import '../widgets/filter_chips.dart';

class ComplaintHistoryScreen extends StatefulWidget {
  const ComplaintHistoryScreen({super.key});

  @override
  State<ComplaintHistoryScreen> createState() => _ComplaintHistoryScreenState();
}

class _ComplaintHistoryScreenState extends State<ComplaintHistoryScreen> {
  String _selectedFilter = 'ALL';
  String _selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).loadComplaints();
    });
  }

  List<ComplaintModel> _getFilteredComplaints(List<ComplaintModel> complaints) {
    List<ComplaintModel> filtered = complaints;

    // Filter by status
    if (_selectedFilter != 'ALL') {
      filtered = filtered.where((c) => c.status == _selectedFilter).toList();
    }

    // Filter by category
    if (_selectedCategory != 'ALL') {
      filtered = filtered.where((c) => c.category == _selectedCategory).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, child) {
          if (complaintProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allComplaints = [
            ...complaintProvider.complaints,
            ...complaintProvider.offlineComplaints,
          ];

          final filteredComplaints = _getFilteredComplaints(allComplaints);

          return RefreshIndicator(
            onRefresh: () async {
              await complaintProvider.loadComplaints();
              await complaintProvider.syncOfflineComplaints();
            },
            child: Column(
              children: [
                // Filters
                _buildFilters(),

                // Complaints List
                Expanded(
                  child: filteredComplaints.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredComplaints.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ComplaintCard(
                        complaint: filteredComplaints[index],
                        onTap: () => context.push('/complaint/${filteredComplaints[index].id}'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/new-complaint'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Filter
          Text(
            'Filter by Status',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
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

          const SizedBox(height: 16),

          // Category Filter
          Text(
            'Filter by Category',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('ALL', 'All'),
                _buildCategoryChip('GARBAGE', 'Garbage'),
                _buildCategoryChip('WATER_SUPPLY', 'Water'),
                _buildCategoryChip('ELECTRICITY', 'Electricity'),
                _buildCategoryChip('DRAINAGE', 'Drainage'),
                _buildCategoryChip('ROAD_DAMAGE', 'Roads'),
                _buildCategoryChip('HEALTH_CENTER', 'Health'),
                _buildCategoryChip('TRANSPORT', 'Transport'),
              ],
            ),
          ),
        ],
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
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = value);
        },
        selectedColor: AppTheme.secondaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'No complaints found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or create a new complaint',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/new-complaint'),
            child: const Text('Create New Complaint'),
          ),
        ],
      ),
    );
  }
}