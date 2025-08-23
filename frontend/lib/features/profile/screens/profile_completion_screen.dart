import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../../../core/services/location_service.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _aadhaarController = TextEditingController();

  String? _selectedDistrict;
  String? _selectedPanchayat;
  String? _selectedVillage;
  String? _selectedWard;

  bool _showAadhaarOtp = false;

  @override
  void dispose() {
    _addressController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_add,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Complete Your Profile',
                            style: AppTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please provide your location details to help us serve you better',
                            style: AppTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location Details',
                            style: AppTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // District Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedDistrict,
                            decoration: const InputDecoration(
                              labelText: 'District',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            items: LocationService.districts.map((district) {
                              return DropdownMenuItem(
                                value: district,
                                child: Text(district),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDistrict = value;
                                _selectedPanchayat = null;
                                _selectedVillage = null;
                                _selectedWard = null;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select district';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Panchayat Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedPanchayat,
                            decoration: const InputDecoration(
                              labelText: 'Panchayat',
                              prefixIcon: Icon(Icons.account_balance_outlined),
                            ),
                            items: _selectedDistrict != null
                                ? LocationService.getPanchayats(_selectedDistrict!).map((panchayat) {
                              return DropdownMenuItem(
                                value: panchayat,
                                child: Text(panchayat),
                              );
                            }).toList()
                                : [],
                            onChanged: _selectedDistrict != null ? (value) {
                              setState(() {
                                _selectedPanchayat = value;
                                _selectedVillage = null;
                                _selectedWard = null;
                              });
                            } : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select panchayat';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Village Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedVillage,
                            decoration: const InputDecoration(
                              labelText: 'Village',
                              prefixIcon: Icon(Icons.home_work_outlined),
                            ),
                            items: _selectedPanchayat != null
                                ? LocationService.getVillages(_selectedDistrict!, _selectedPanchayat!).map((village) {
                              return DropdownMenuItem(
                                value: village,
                                child: Text(village),
                              );
                            }).toList()
                                : [],
                            onChanged: _selectedPanchayat != null ? (value) {
                              setState(() {
                                _selectedVillage = value;
                                _selectedWard = null;
                              });
                            } : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select village';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Ward Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedWard,
                            decoration: const InputDecoration(
                              labelText: 'Ward',
                              prefixIcon: Icon(Icons.map_outlined),
                            ),
                            items: _selectedVillage != null
                                ? LocationService.getWards(_selectedDistrict!, _selectedPanchayat!, _selectedVillage!).map((ward) {
                              return DropdownMenuItem(
                                value: ward,
                                child: Text(ward),
                              );
                            }).toList()
                                : [],
                            onChanged: _selectedVillage != null ? (value) {
                              setState(() {
                                _selectedWard = value;
                              });
                            } : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select ward';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Address Field
                          TextFormField(
                            controller: _addressController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Home Address',
                              hintText: 'Enter your complete address',
                              prefixIcon: Icon(Icons.home_outlined),
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your address';
                              }
                              if (value.length < 5) {
                                return 'Address must be at least 5 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Aadhaar Verification Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aadhaar Verification',
                            style: AppTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // Aadhaar Number Field
                          TextFormField(
                            controller: _aadhaarController,
                            keyboardType: TextInputType.number,
                            maxLength: 12,
                            decoration: const InputDecoration(
                              labelText: 'Aadhaar Number',
                              hintText: 'Enter 12-digit Aadhaar number',
                              prefixIcon: Icon(Icons.credit_card_outlined),
                              counterText: '',
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Aadhaar number';
                              }
                              if (value.length != 12) {
                                return 'Aadhaar number must be 12 digits';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _showAadhaarOtp = value.length == 12;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // Verify Aadhaar Button
                          if (_showAadhaarOtp && !profileProvider.aadhaarVerified)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: profileProvider.isLoading ? null : _handleAadhaarOtp,
                                icon: const Icon(Icons.verified_user_outlined),
                                label: const Text('Verify Aadhaar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  side: const BorderSide(color: AppTheme.primaryColor),
                                ),
                              ),
                            ),

                          // Aadhaar Verified Status
                          if (profileProvider.aadhaarVerified)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.successColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppTheme.successColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Aadhaar verified successfully!',
                                    style: TextStyle(
                                      color: AppTheme.successColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Error Message
                  if (profileProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.errorColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              profileProvider.error!,
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Complete Profile Button
                  ElevatedButton(
                    onPressed: profileProvider.isLoading || !profileProvider.aadhaarVerified
                        ? null
                        : () => _handleCompleteProfile(profileProvider),
                    child: profileProvider.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Complete Profile'),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleAadhaarOtp() async {
    if (_aadhaarController.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 12-digit Aadhaar number'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.clearError();

    final success = await profileProvider.generateAadhaarOtp(_aadhaarController.text);

    if (success && mounted) {
      // Show OTP in SnackBar for development
      if (profileProvider.developmentOtp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Development Aadhaar OTP: ${profileProvider.developmentOtp}'),
            backgroundColor: AppTheme.primaryColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Show OTP input dialog
      _showAadhaarOtpDialog(profileProvider);
    }
  }

  void _showAadhaarOtpDialog(ProfileProvider profileProvider) {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify Aadhaar OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 6-digit OTP sent for Aadhaar verification:'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Enter OTP',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<ProfileProvider>(
            builder: (context, provider, child) => ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                if (otpController.text.length != 6) return;

                final success = await provider.verifyAadhaarOtp(
                  _aadhaarController.text,
                  otpController.text,
                );

                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Aadhaar verified successfully!'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                }
              },
              child: provider.isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Verify'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCompleteProfile(ProfileProvider profileProvider) async {
    if (!_formKey.currentState!.validate()) return;

    profileProvider.clearError();

    final success = await profileProvider.completeProfile(
      district: _selectedDistrict!,
      panchayat: _selectedPanchayat!,
      village: _selectedVillage!,
      ward: _selectedWard!,
      homeAddress: _addressController.text.trim(),
      aadhaarNumber: _aadhaarController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile completed successfully!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );

      // Navigate to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }
}