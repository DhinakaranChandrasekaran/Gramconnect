import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gramconnect/features/garbage/screens/garbage_schedule_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/profile_completion_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/complaints/screens/new_complaint_screen.dart';
import '../../features/complaints/screens/complaint_history_screen.dart';
import '../../features/complaints/screens/complaint_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/garbage/screens/garbage_schedule_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_login_screen.dart';
import '../../features/admin/screens/super_admin_screen.dart';
import '../../features/admin/screens/complaint_management_screen.dart';
import '../../features/admin/screens/missed_pickup_management_screen.dart';
import '../../features/admin/screens/user_management_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isLoggedIn;
      final currentLocation = state.uri.toString();

      // If not logged in and trying to access protected route
      if (!isLoggedIn && currentLocation != '/welcome' && currentLocation != '/login' && currentLocation != '/signup' && currentLocation != '/profile-completion') {
        return '/login';
      }

      // If logged in and trying to access auth routes
      if (isLoggedIn && (currentLocation == '/welcome' || currentLocation == '/login' || currentLocation == '/signup')) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/profile-completion',
        builder: (context, state) {
          final userData = state.extra as Map<String, String>? ?? {};
          return ProfileCompletionScreen(
            userData: userData,
          );
        },
      ),
      GoRoute(
        path: '/new-complaint',
        builder: (context, state) => const NewComplaintScreen(),
      ),
      GoRoute(
        path: '/complaint-history',
        builder: (context, state) => const ComplaintHistoryScreen(),
      ),
      GoRoute(
        path: '/complaint/:id',
        builder: (context, state) {
          final complaintId = state.pathParameters['id'] ?? '';
          return ComplaintDetailScreen(complaintId: complaintId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/garbage-collection',
        builder: (context, state) => const GarbageScheduleScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/super-admin',
        builder: (context, state) => const SuperAdminScreen(),
      ),
      GoRoute(
        path: '/admin/complaints',
        builder: (context, state) => const ComplaintManagementScreen(),
      ),
      GoRoute(
        path: '/admin/missed-pickups',
        builder: (context, state) => const MissedPickupManagementScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found'),
      ),
    ),
  );
}