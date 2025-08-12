import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/complaint_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/stats_card.dart';
import '../widgets/category_card.dart';
import '../widgets/recent_complaints.dart';
import '../../garbage/widgets/garbage_schedule_section.dart'; // ✅ imported

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ComplaintProvider>(context, listen: false).loadComplaints();
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
      // Home - already here
        break;
      case 1:
        context.push('/complaint-history');
        break;
      case 2:
        context.push('/new-complaint');
        break;
      case 3:
        context.push('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GramConnect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, ComplaintProvider>(
        builder: (context, authProvider, complaintProvider, child) {
          final user = authProvider.user;

          return RefreshIndicator(
            onRefresh: () async {
              await complaintProvider.loadComplaints();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(user?.fullName ?? 'User', user?.village ?? ''),

                  const SizedBox(height: 24),

                  // Stats Cards
                  _buildStatsSection(complaintProvider),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),

                  const SizedBox(height: 24),

                  // Categories
                  _buildCategoriesSection(),

                  const SizedBox(height: 24),

                  // 🔽 Garbage + Missed Pickup Section
                  const GarbageScheduleSection(),

                  const SizedBox(height: 24),

                  // Recent Complaints
                  RecentComplaints(
                    complaints: complaintProvider.complaints.take(3).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'New Complaint',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(String name, String village) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  village,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.location_city,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ComplaintProvider complaintProvider) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Total',
            value: complaintProvider.totalComplaints.toString(),
            color: Colors.blue,
            icon: Icons.assignment,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'Pending',
            value: complaintProvider.pendingComplaints.toString(),
            color: Colors.orange,
            icon: Icons.pending,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'Resolved',
            value: complaintProvider.resolvedComplaints.toString(),
            color: Colors.green,
            icon: Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'New Complaint',
                Icons.add_circle,
                Colors.red,
                    () => context.push('/new-complaint'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Track Status',
                Icons.track_changes,
                Colors.blue,
                    () => context.push('/complaint-history'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Report Issues',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            CategoryCard(
              title: 'Garbage',
              icon: Icons.delete,
              color: AppColors.getCategoryColor('GARBAGE'),
              onTap: () => _navigateToNewComplaint('GARBAGE'),
            ),
            CategoryCard(
              title: 'Water Supply',
              icon: Icons.water_drop,
              color: AppColors.getCategoryColor('WATER_SUPPLY'),
              onTap: () => _navigateToNewComplaint('WATER_SUPPLY'),
            ),
            CategoryCard(
              title: 'Electricity',
              icon: Icons.electrical_services,
              color: AppColors.getCategoryColor('ELECTRICITY'),
              onTap: () => _navigateToNewComplaint('ELECTRICITY'),
            ),
            CategoryCard(
              title: 'Drainage',
              icon: Icons.cleaning_services,
              color: AppColors.getCategoryColor('DRAINAGE'),
              onTap: () => _navigateToNewComplaint('DRAINAGE'),
            ),
            CategoryCard(
              title: 'Road Damage',
              icon: Icons.construction,
              color: AppColors.getCategoryColor('ROAD_DAMAGE'),
              onTap: () => _navigateToNewComplaint('ROAD_DAMAGE'),
            ),
            CategoryCard(
              title: 'Health Center',
              icon: Icons.local_hospital,
              color: AppColors.getCategoryColor('HEALTH_CENTER'),
              onTap: () => _navigateToNewComplaint('HEALTH_CENTER'),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToNewComplaint(String category) {
    context.push('/new-complaint', extra: {'category': category});
  }
}
