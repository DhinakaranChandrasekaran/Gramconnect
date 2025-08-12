import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/auth_button.dart';

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
  final List<TextEditingController> _controllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(6, (index) => FocusNode());

  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showErrorSnackBar('Please enter complete OTP');
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.verifyOtp(
        identifier: widget.identifier,
        otp: otp,
        type: widget.type,
      );

      if (success) {
        context.go('/');
      } else {
        _showErrorSnackBar('Invalid OTP. Please try again.');
        _clearOtp();
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
      _clearOtp();
    }
  }

  Future<void> _resendOtp() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resendOtp(
        identifier: widget.identifier,
        type: widget.type,
      );

      if (success) {
        _clearOtp();
        _startResendTimer();
        _showSuccessSnackBar('OTP resent successfully');
      } else {
        _showErrorSnackBar('Failed to resend OTP. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _clearOtp() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
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
        title: const Text('OTP Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Header
              _buildHeader(),

              const SizedBox(height: 40),

              // OTP Input
              _buildOtpInput(),

              const SizedBox(height: 32),

              // Verify Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return AuthButton(
                    text: 'Verify OTP',
                    onPressed: authProvider.isLoading ? null : _verifyOtp,
                    isLoading: authProvider.isLoading,
                  );
                },
              ),

              const SizedBox(height: 24),

              // Resend OTP
              _buildResendSection(),
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
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.message,
            size: 40,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Enter Verification Code',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.identifier,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: const InputDecoration(
              counterText: '',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  _focusNodes[index].unfocus();
                  _verifyOtp();
                }
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          "Didn't receive the code?",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        if (_canResend) ...[
          TextButton(
            onPressed: _resendOtp,
            child: const Text(
              'Resend OTP',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ] else ...[
          Text(
            'Resend in $_resendCountdown seconds',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}