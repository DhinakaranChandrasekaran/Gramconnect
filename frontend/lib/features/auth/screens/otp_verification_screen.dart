import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/env.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String identifier;
  final String type;

  const OtpVerificationScreen({
    super.key,
    required this.identifier,
    required this.type,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    Environment.otpLength,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    Environment.otpLength,
        (index) => FocusNode(),
  );

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Provider.of<AuthProvider>(context, listen: false).backToAuth();
          },
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Header Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.message_outlined,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'Enter Verification Code',
                  style: AppTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  'We sent a ${Environment.otpLength}-digit code to\n${_getMaskedIdentifier()}',
                  style: AppTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    Environment.otpLength,
                        (index) => _buildOtpField(index),
                  ),
                ),

                const SizedBox(height: 24),

                // Error Message
                if (authProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.errorColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppTheme.errorColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authProvider.error!,
                            style: const TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Verify Button
                ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : _handleVerifyOtp,
                  child: authProvider.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text('Verify Code'),
                ),

                const SizedBox(height: 16),

                // Resend OTP
                _buildResendSection(authProvider),

                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < Environment.otpLength - 1) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }

          // Auto verify when all fields are filled
          if (_isOtpComplete()) {
            _handleVerifyOtp();
          }
        },
      ),
    );
  }

  Widget _buildResendSection(AuthProvider authProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive code? ',
          style: AppTheme.bodyMedium,
        ),
        authProvider.otpResendCooldown > 0
            ? Text(
          'Resend in ${authProvider.otpResendCooldown}s',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textTertiary,
          ),
        )
            : GestureDetector(
          onTap: authProvider.isLoading ? null : _handleResendOtp,
          child: Text(
            'Resend',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _getMaskedIdentifier() {
    if (widget.type == 'EMAIL') {
      final parts = widget.identifier.split('@');
      if (parts.length == 2) {
        final username = parts[0];
        final domain = parts[1];
        final maskedUsername = username.length > 2
            ? '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}'
            : username;
        return '$maskedUsername@$domain';
      }
    } else if (widget.type == 'PHONE') {
      if (widget.identifier.length > 4) {
        final last4 = widget.identifier.substring(widget.identifier.length - 4);
        return '${'*' * (widget.identifier.length - 4)}$last4';
      }
    }
    return widget.identifier;
  }

  bool _isOtpComplete() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getOtp() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _handleVerifyOtp() async {
    if (!_isOtpComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.verifyOtp(
      identifier: widget.identifier,
      type: widget.type,
      otp: _getOtp(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verified successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Navigate based on profile completion status
      if (authProvider.profileCompleted) {
        // Navigate to dashboard based on role
        if (authProvider.userRole == 'ADMIN' || authProvider.userRole == 'SUPER_ADMIN') {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        // Navigate to profile completion
        Navigator.pushReplacementNamed(context, '/profile-completion');
      }
    }
  }

  void _handleResendOtp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.resendOtp();

    if (success && mounted) {
      // Show OTP in SnackBar for development
      if (authProvider.developmentOtp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Development OTP: ${authProvider.developmentOtp}'),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );

      // Clear existing input
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }
}