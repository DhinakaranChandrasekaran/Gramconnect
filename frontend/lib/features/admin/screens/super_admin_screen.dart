import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../services/super_admin_service.dart';
import '../widgets/admin_menu_item.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final SuperAdminService _superAdminService = SuperAdminService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  List<dynamic> _admins = [];
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final admins = await _superAdminService.getAllAdmins();
      final users = await _superAdminService.getAllUsers();
      setState(() {
        _admins = admins;
        _users = users;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load data: ${e.toString()}');
    }
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _superAdminService.createAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      _showSuccessSnackBar('Admin created successfully');
      _clearForm();
      _loadData();
    } catch (e) {
      _showErrorSnackBar('Failed to create admin: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promoteUser(String userId, String userName) async {
    final confirmed = await _showConfirmDialog(
      'Promote User',
      'Are you sure you want to promote $userName to admin?',
    );

    if (confirmed) {
      try {
        await _superAdminService.promoteUserToAdmin(userId);
        _showSuccessSnackBar('User promoted to admin successfully');
        _loadData();
      } catch (e) {
        _showErrorSnackBar('Failed to promote user: ${e.toString()}');
      }
    }
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
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

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create Admin Section
            _buildCreateAdminSection(),

            const SizedBox(height: 32),

            // Admin Management
            _buildAdminManagementSection(),

            const SizedBox(height: 32),

            // User Promotion Section
            _buildUserPromotionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAdminSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Admin',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter password';
                  }
                  if (value!.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Admin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 16),

            if (_admins.isEmpty) ...[
              const Center(
                child: Text('No admins found'),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _admins.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final admin = _admins[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.secondaryColor,
                      child: Text(
                        admin['fullName'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(admin['fullName']),
                    subtitle: Text('${admin['email']} • ${admin['role']}'),
                    trailing: admin['active']
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserPromotionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Promote Users to Admin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 16),

            if (_users.isEmpty) ...[
              const Center(
                child: Text('No users found'),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.take(10).length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        user['fullName'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(user['fullName']),
                    subtitle: Text(user['email'] ?? user['phoneNumber'] ?? ''),
                    trailing: ElevatedButton(
                      onPressed: () => _promoteUser(user['id'], user['fullName']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Promote'),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}