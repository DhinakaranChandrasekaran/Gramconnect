import 'package:flutter/material.dart';

import 'features/splash/splash_screen.dart';
import 'features/welcome/welcome_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/admin/screens/admin_login_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/admin_complaints_screen.dart';
import 'features/navigation/main_navigation.dart';
import 'features/home/home_screen.dart';

// Complaints
import 'features/complaints/screens/new_complaint_screen.dart';
import 'features/complaints/screens/complaints_list_screen.dart';
import 'features/complaints/screens/complaint_form_screen.dart';

// Garbage
import 'features/garbage/screens/garbage_screen.dart';

// Notifications
import 'features/notifications/screens/notifications_screen.dart';

// Profile
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/profile_completion_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String adminLogin = '/admin-login';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminComplaints = '/admin-complaints';
  static const String home = '/home';
  static const String mainNavigation = '/main';
  static const String newComplaint = '/new-complaint';
  static const String complaints = '/complaints';
  static const String complaintDetails = '/complaint-details';
  static const String garbage = '/garbage';
  static const String missedPickup = '/missed-pickup';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String profileCompletion = '/profile-completion';
  static const String complaintForm = '/complaint-form';
  static const String changePassword = '/change-password';
  static const String notificationSettings = '/notification-settings';
  static const String help = '/help';
  static const String about = '/about';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case adminLogin:
        return MaterialPageRoute(builder: (_) => const AdminLoginScreen());

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case home:
      case mainNavigation:
        return MaterialPageRoute(builder: (_) => const MainNavigation());

      case newComplaint:
      case complaintForm:
        return MaterialPageRoute(builder: (_) => const ComplaintFormScreen());

      case complaints:
        return MaterialPageRoute(builder: (_) => const ComplaintsListScreen());

      case garbage:
        return MaterialPageRoute(builder: (_) => const GarbageScreen());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case profileCompletion:
        return MaterialPageRoute(builder: (_) => const ProfileCompletionScreen());

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case adminComplaints:
        return MaterialPageRoute(builder: (_) => const AdminComplaintsScreen());

    // Placeholder screens for routes that aren't implemented yet
      case complaintDetails:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Complaint Details'),
        );

      case missedPickup:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Report Missed Pickup'),
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Edit Profile'),
        );

      case changePassword:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Change Password'),
        );

      case notificationSettings:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Notification Settings'),
        );

      case help:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Help & Support'),
        );

      case about:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('About'),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }

  static Widget _buildPlaceholderScreen(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This screen is under development',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}