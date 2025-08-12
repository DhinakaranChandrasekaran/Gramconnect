import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/widgets/auth_form_field.dart';
import '../../auth/widgets/auth_button.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showOtpField = false;
  bool _obscurePassword = true;
  String? _pendingEmail;
  String? _testOtp;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final result = await authProvider.adminLogin(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        if (result['requiresOtpVerification'] == true) {
          setState(() {
            _showOtpField = true;
            _pendingEmail = email;
            _testOtp = result['otp'];
          });
          _showSuccessSnackBar('OTP sent to $email');
        } else {
          context.go('/admin');
        }
      } else {
        _showErrorSnackBar(result['message'] ?? 'Admin login failed');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _verifyAdminOtp() async {
    if (_otpController.text.length != 6) {
      _showErrorSnackBar('Please enter complete OTP');
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.verifyOtp(
        identifier: _pendingEmail!,
        otp: _otpController.text,
        type: 'EMAIL_LOGIN',
      );

      if (success) {
        context.go('/admin');
      } else {
        _showErrorSnackBar('Invalid OTP. Please try again.');
        _otpController.clear();
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
      _otpController.clear();
    }
  }

  Future<void> _resendAdminOtp() async {
    if (_pendingEmail == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resendOtp(
        identifier: _pendingEmail!,
        type: 'EMAIL_LOGIN',
      );

      if (success) {
        _showSuccessSnackBar('OTP resent successfully');
        _otpController.clear();
      } else {
        _showErrorSnackBar('Failed to resend OTP');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Admin Header
              _buildAdminHeader(),

              const SizedBox(height: 40),

              // Admin Login Form
              _buildAdminLoginForm(),

              const SizedBox(height: 24),

              // Back to User Login
              _buildBackToUserLogin(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Admin Login',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Access admin panel',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAdminLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Input
              AuthFormField(
                controller: _emailController,
                label: 'Admin Email',
                keyboardType: TextInputType.emailAddress,
                enabled: !_showOtpField,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your admin email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password Field
              if (!_showOtpField) ...[
                AuthFormField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // OTP Field (shown after login)
              if (_showOtpField) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Admin OTP Verification',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 6-digit OTP sent to ${_pendingEmail}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AuthFormField(
                  controller: _otpController,
                  label: 'Enter Admin OTP',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter OTP';
                    }
                    if (value!.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                ),

                // Display OTP for testing
                if (_testOtp != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Test OTP: $_testOtp',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showOtpField = false;
                          _pendingEmail = null;
                          _otpController.clear();
                          _testOtp = null;
                        });
                      },
                      child: const Text('← Back to Login'),
                    ),
                    TextButton(
                      onPressed: _resendAdminOtp,
                      child: const Text('Resend OTP'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Login Button
              AuthButton(
                text: _showOtpField ? 'Verify Admin OTP' : 'Admin Login',
                onPressed: authProvider.isLoading ? null : (_showOtpField ? _verifyAdminOtp : _handleAdminLogin),
                isLoading: authProvider.isLoading,
                backgroundColor: AppTheme.secondaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackToUserLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Not an admin? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text(
            'User Login',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}