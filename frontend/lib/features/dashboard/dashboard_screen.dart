import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../auth/providers/auth_provider.dart';
import '../complaints/providers/complaint_provider.dart';
import '../garbage/providers/garbage_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/complaints_section.dart';
import 'widgets/garbage_section.dart';
import 'widgets/recent_complaints_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    final garbageProvider = Provider.of<GarbageProvider>(context, listen: false);

    await Future.wait([
      complaintProvider.fetchUserComplaints(),
      garbageProvider.fetchSchedules(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with green background
                const DashboardHeader(),

                const SizedBox(height: 16),

                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Complaints Section
                      const ComplaintsSection(),

                      const SizedBox(height: 16),

                      // Garbage Collection Section (3/4 width)
                      const GarbageSection(),

                      const SizedBox(height: 16),

                      // Recent Complaints Section
                      const RecentComplaintsSection(),

                      const SizedBox(height: 80), // Bottom padding for FAB
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new-complaint');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}