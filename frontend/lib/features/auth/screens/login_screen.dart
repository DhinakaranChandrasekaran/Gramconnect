import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showOtpField = false;
  bool _obscurePassword = true;
  String? _pendingIdentifier;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;

      final result = await authProvider.login(
        identifier: identifier,
        password: password,
      );

      if (result['success'] == true) {
        if (result['requiresOtpVerification'] == true) {
          setState(() {
            _showOtpField = true;
            _pendingIdentifier = identifier;
          });
          _showSuccessSnackBar('OTP sent to $identifier');
        } else {
          context.go('/');
        }
      } else {
        _showErrorSnackBar(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _showErrorSnackBar('Please enter complete OTP');
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.verifyOtp(
        identifier: _pendingIdentifier!,
        otp: _otpController.text,
        type: _pendingIdentifier!.contains('@') ? 'EMAIL_LOGIN' : 'PHONE_LOGIN',
      );

      if (success) {
        context.go('/');
      } else {
        _showErrorSnackBar('Invalid OTP. Please try again.');
        _otpController.clear();
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
      _otpController.clear();
    }
  }

  Future<void> _resendOtp() async {
    if (_pendingIdentifier == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resendOtp(
        identifier: _pendingIdentifier!,
        type: _pendingIdentifier!.contains('@') ? 'EMAIL_LOGIN' : 'PHONE_LOGIN',
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

              // Logo and Welcome Text
              _buildHeader(),

              const SizedBox(height: 40),

              // Login Form
              _buildLoginForm(),

              const SizedBox(height: 24),

              // Sign Up Link
              _buildSignUpLink(),

              const SizedBox(height: 16),

              // Admin Login Link
              _buildAdminLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.location_city,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome Back!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email or Phone Input
              AuthFormField(
                controller: _identifierController,
                label: 'Email or Phone Number',
                keyboardType: TextInputType.text,
                enabled: !_showOtpField,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email or phone number';
                  }
                  // Check if it's email or phone
                  if (value!.contains('@')) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  } else {
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password Field
              AuthFormField(
                controller: _passwordController,
                label: 'Password',
                obscureText: _obscurePassword,
                enabled: !_showOtpField,
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

              // OTP Field (shown after login)
              if (_showOtpField) ...[
                AuthFormField(
                  controller: _otpController,
                  label: 'Enter OTP',
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showOtpField = false;
                          _pendingIdentifier = null;
                          _otpController.clear();
                        });
                      },
                      child: const Text('← Back to Login'),
                    ),
                    TextButton(
                      onPressed: _resendOtp,
                      child: const Text('Resend OTP'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Login Button
              AuthButton(
                text: _showOtpField ? 'Verify OTP' : 'Login',
                onPressed: authProvider.isLoading ? null : (_showOtpField ? _verifyOtp : _handleLogin),
                isLoading: authProvider.isLoading,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.push('/signup'),
          child: const Text(
            'Sign Up',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Admin? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => context.push('/admin-login'),
          child: Text(
            'Admin Login',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryColor,
            ),
          ),
        ),
      ],
    );
  }
}