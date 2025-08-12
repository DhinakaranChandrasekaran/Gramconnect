import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, user.fullName, user.email ?? user.phoneNumber ?? ''),

                const SizedBox(height: 24),

                // Profile Information
                ProfileInfoCard(user: user),

                const SizedBox(height: 24),

                // Menu Items
                _buildMenuItems(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String contact) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'User',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () {
            // TODO: Navigate to edit profile screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit profile feature coming soon')),
            );
          },
        ),

        const SizedBox(height: 12),

        ProfileMenuItem(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage notification preferences',
          onTap: () {
            // TODO: Navigate to notification settings
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification settings coming soon')),
            );
          },
        ),

        const SizedBox(height: 12),

        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return ProfileMenuItem(
              icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              title: 'Theme',
              subtitle: themeProvider.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
              onTap: () => themeProvider.toggleTheme(),
            );
          },
        ),

        const SizedBox(height: 12),

        ProfileMenuItem(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            // TODO: Navigate to help screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help & support coming soon')),
            );
          },
        ),

        const SizedBox(height: 12),

        ProfileMenuItem(
          icon: Icons.info,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () {
            _showAboutDialog(context);
          },
        ),

        const SizedBox(height: 24),

        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _showLogoutDialog(context, authProvider),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'GramConnect',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.location_city,
          size: 30,
          color: Colors.white,
        ),
      ),
      children: [
        const Text('Smart Village Grievance & Civic Service Reporting System'),
        const SizedBox(height: 8),
        const Text('Built with ❤️ for Smart Villages Initiative'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}