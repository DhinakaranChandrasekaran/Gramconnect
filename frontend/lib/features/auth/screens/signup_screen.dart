import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showOtpField = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _pendingPhoneNumber;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final result = await authProvider.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (result['success'] == true) {
        if (result['requiresOtpVerification'] == true) {
          setState(() {
            _showOtpField = true;
            _pendingPhoneNumber = _phoneController.text.trim();
          });
          _showSuccessSnackBar('OTP sent to ${_phoneController.text}');
        } else {
          // Navigate to profile completion
          context.push('/profile-completion', extra: {
            'fullName': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phoneNumber': _phoneController.text.trim(),
          });
        }
      } else {
        _showErrorSnackBar(result['message'] ?? 'Registration failed');
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
        identifier: _pendingPhoneNumber!,
        otp: _otpController.text,
        type: 'PHONE_REGISTRATION',
      );

      if (success) {
        // Navigate to profile completion
        context.push('/profile-completion', extra: {
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
        });
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
    if (_pendingPhoneNumber == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resendOtp(
        identifier: _pendingPhoneNumber!,
        type: 'PHONE_REGISTRATION',
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
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _buildSignupForm(),
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Join GramConnect',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'உங்கள் கணக்கை உருவாக்குங்கள்',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Full Name
              AuthFormField(
                controller: _nameController,
                label: 'Full Name',
                enabled: !_showOtpField,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your full name';
                  }
                  if (value!.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email
              AuthFormField(
                controller: _emailController,
                label: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                enabled: !_showOtpField,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Phone Number
              AuthFormField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                enabled: !_showOtpField,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value!)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password
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
                    return 'Please enter a password';
                  }
                  if (value!.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Confirm Password
              AuthFormField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                obscureText: _obscureConfirmPassword,
                enabled: !_showOtpField,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // OTP Field (shown after signup)
              if (_showOtpField) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'OTP Verification',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 6-digit OTP sent to ${_pendingPhoneNumber}',
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
                          _pendingPhoneNumber = null;
                          _otpController.clear();
                        });
                      },
                      child: const Text('← Back to Form'),
                    ),
                    TextButton(
                      onPressed: _resendOtp,
                      child: const Text('Resend OTP'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Signup Button
              AuthButton(
                text: _showOtpField ? 'Verify OTP' : 'Next',
                onPressed: authProvider.isLoading ? null : (_showOtpField ? _verifyOtp : _handleSignup),
                isLoading: authProvider.isLoading,
              ),

              const SizedBox(height: 16),

              // Login Link
              if (!_showOtpField) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}