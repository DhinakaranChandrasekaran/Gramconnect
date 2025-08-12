import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/location_service.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_button.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final Map<String, String> userData;

  const ProfileCompletionScreen({
    super.key,
    required this.userData,
  });

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _aadhaarOtpController = TextEditingController();

  String? _selectedDistrict;
  String? _selectedPanchayat;
  String? _selectedWard;
  bool _isAadhaarVerified = false;
  bool _showAadhaarOtp = false;
  bool _isLoadingAadhaarOtp = false;

  final LocationService _locationService = LocationService();
  List<String> _districts = [];
  List<String> _panchayats = [];
  List<String> _wards = [];
  bool _isLoadingDistricts = false;
  bool _isLoadingPanchayats = false;
  bool _isLoadingWards = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData['fullName'] ?? '';
    _loadDistricts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _aadhaarController.dispose();
    _aadhaarOtpController.dispose();
    super.dispose();
  }

  Future<void> _loadDistricts() async {
    setState(() => _isLoadingDistricts = true);
    try {
      final districts = await _locationService.getDistricts();
      setState(() {
        _districts = districts;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      setState(() => _isLoadingDistricts = false);
      _showErrorSnackBar('Failed to load districts: ${e.toString()}');
    }
  }

  Future<void> _loadPanchayats(String district) async {
    setState(() => _isLoadingPanchayats = true);
    try {
      final panchayats = await _locationService.getPanchayats(district);
      setState(() {
        _panchayats = panchayats;
        _isLoadingPanchayats = false;
      });
    } catch (e) {
      setState(() => _isLoadingPanchayats = false);
      _showErrorSnackBar('Failed to load panchayats: ${e.toString()}');
    }
  }

  Future<void> _loadWards(String district, String panchayat) async {
    setState(() => _isLoadingWards = true);
    try {
      final wards = await _locationService.getWards(district, panchayat);
      setState(() {
        _wards = wards;
        _isLoadingWards = false;
      });
    } catch (e) {
      setState(() => _isLoadingWards = false);
      _showErrorSnackBar('Failed to load wards: ${e.toString()}');
    }
  }

  Future<void> _verifyAadhaar() async {
    if (_aadhaarController.text.length != 12) {
      _showErrorSnackBar('Please enter a valid 12-digit Aadhaar number');
      return;
    }

    setState(() => _isLoadingAadhaarOtp = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.sendAadhaarOtp(
        aadhaarNumber: _aadhaarController.text.trim(),
        phoneNumber: widget.userData['phoneNumber']!,
      );

      setState(() {
        _showAadhaarOtp = true;
        _isLoadingAadhaarOtp = false;
      });

      _showSuccessSnackBar(response['message'] ?? 'OTP sent to your phone');
    } catch (e) {
      setState(() => _isLoadingAadhaarOtp = false);
      _showErrorSnackBar('Failed to send Aadhaar OTP: ${e.toString()}');
    }
  }

  Future<void> _verifyAadhaarOtp() async {
    if (_aadhaarOtpController.text.length != 6) {
      _showErrorSnackBar('Please enter complete OTP');
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.verifyAadhaarOtp(
        aadhaarNumber: _aadhaarController.text.trim(),
        otp: _aadhaarOtpController.text.trim(),
      );

      if (response['verified'] == true) {
        setState(() {
          _isAadhaarVerified = true;
          _showAadhaarOtp = false;
        });
        _showSuccessSnackBar(response['message'] ?? 'Aadhaar verified!');
      } else {
        _showErrorSnackBar('Invalid OTP. Please try again.');
        _aadhaarOtpController.clear();
      }
    } catch (e) {
      _showErrorSnackBar('OTP verification failed: ${e.toString()}');
      _aadhaarOtpController.clear();
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDistrict == null || _selectedPanchayat == null || _selectedWard == null) {
      _showErrorSnackBar('Please select District, Panchayat, and Ward');
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Update user profile with location details
      await authProvider.updateProfile(
        fullName: _nameController.text.trim(),
        email: widget.userData['email'],
        phoneNumber: widget.userData['phoneNumber'],
        district: _selectedDistrict!,
        panchayat: _selectedPanchayat!,
        ward: _selectedWard!,
        homeAddress: _addressController.text.trim(),
        aadhaarNumber: _isAadhaarVerified ? _aadhaarController.text.trim() : null,
      );

      _showSuccessSnackBar('Profile completed successfully!');

      // Navigate to home
      context.go('/');
    } catch (e) {
      _showErrorSnackBar('Failed to save profile: ${e.toString()}');
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
        title: const Text('Complete Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Complete Your Profile',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'உங்கள் விவரங்களை பூர்த்தி செய்யுங்கள்',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Required Fields Section
                _buildSectionHeader('Required Information', true),
                const SizedBox(height: 16),

                // Full Name (pre-filled)
                AuthFormField(
                  controller: _nameController,
                  label: 'Full Name',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // District Dropdown
                _buildDropdown(
                  label: 'District',
                  value: _selectedDistrict,
                  items: _districts,
                  isLoading: _isLoadingDistricts,
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                      _selectedPanchayat = null;
                      _selectedWard = null;
                      _panchayats = [];
                      _wards = [];
                    });
                    if (value != null) {
                      _loadPanchayats(value);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Panchayat Dropdown
                _buildDropdown(
                  label: 'Panchayat',
                  value: _selectedPanchayat,
                  items: _panchayats,
                  isLoading: _isLoadingPanchayats,
                  onChanged: (value) {
                    setState(() {
                      _selectedPanchayat = value;
                      _selectedWard = null;
                      _wards = [];
                    });
                    if (value != null && _selectedDistrict != null) {
                      _loadWards(_selectedDistrict!, value);
                    }
                  },
                  enabled: _selectedDistrict != null,
                ),

                const SizedBox(height: 16),

                // Ward Dropdown
                _buildDropdown(
                  label: 'Ward',
                  value: _selectedWard,
                  items: _wards,
                  isLoading: _isLoadingWards,
                  onChanged: (value) {
                    setState(() {
                      _selectedWard = value;
                    });
                  },
                  enabled: _selectedPanchayat != null,
                ),

                const SizedBox(height: 16),

                // Home Address
                AuthFormField(
                  controller: _addressController,
                  label: 'Home Address',
                  maxLines: 3,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter your home address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Optional Fields Section
                _buildSectionHeader('Optional Information', false),
                const SizedBox(height: 16),

                // Aadhaar Verification Section
                _buildAadhaarSection(),

                const SizedBox(height: 32),

                // Save Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return AuthButton(
                      text: 'Save Profile',
                      onPressed: authProvider.isLoading ? null : _saveProfile,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isRequired) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            enabled: enabled && !isLoading,
            suffixIcon: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : null,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: enabled && !isLoading ? onChanged : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
        ),
        if (isLoading) ...[
          const SizedBox(height: 4),
          Text(
            'Loading $label...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAadhaarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aadhaar Verification (Optional)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Verify your Aadhaar for enhanced security and faster services',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Aadhaar Number Input
          Row(
            children: [
              Expanded(
                child: AuthFormField(
                  controller: _aadhaarController,
                  label: 'Aadhaar Number',
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  enabled: !_isAadhaarVerified,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 12) {
                        return 'Aadhaar number must be 12 digits';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              if (!_isAadhaarVerified) ...[
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _aadhaarController.text.length == 12 && !_isLoadingAadhaarOtp
                        ? _verifyAadhaar
                        : null,
                    child: _isLoadingAadhaarOtp
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Verify'),
                  ),
                ),
              ] else ...[
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Verified',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // OTP Verification (shown after clicking Verify)
          if (_showAadhaarOtp) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter OTP sent to your registered mobile number',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AuthFormField(
                          controller: _aadhaarOtpController,
                          label: 'Enter OTP',
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _aadhaarOtpController.text.length == 6
                              ? _verifyAadhaarOtp
                              : null,
                          child: const Text('Verify'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}