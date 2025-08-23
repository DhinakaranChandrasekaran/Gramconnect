import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../../../core/services/location_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedDistrict;
  String? _selectedPanchayat;
  String? _selectedVillage;
  String? _selectedWard;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.fetchUserProfile();

    if (profileProvider.userProfile != null) {
      final profile = profileProvider.userProfile!;
      _fullNameController.text = profile['fullName'] ?? '';
      _addressController.text = profile['homeAddress'] ?? '';
      _selectedDistrict = profile['district'];
      _selectedPanchayat = profile['panchayat'];
      _selectedVillage = profile['village'];
      _selectedWard = profile['ward'];
      setState(() {});
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading && profileProvider.userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Edit Your Profile',
                            style: AppTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Personal Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: AppTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),

                          // Full Name Field
                          TextFormField(
                            controller: _fullNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location Details',
                            style: AppTheme.titleMedium,
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
                              return null;
                            },
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

                  // Update Button
                  ElevatedButton(
                    onPressed: profileProvider.isLoading
                        ? null
                        : () => _handleUpdateProfile(profileProvider),
                    child: profileProvider.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Update Profile'),
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

  void _handleUpdateProfile(ProfileProvider profileProvider) async {
    if (!_formKey.currentState!.validate()) return;

    profileProvider.clearError();

    final success = await profileProvider.updateProfile(
      fullName: _fullNameController.text.trim(),
      district: _selectedDistrict,
      panchayat: _selectedPanchayat,
      village: _selectedVillage,
      ward: _selectedWard,
      homeAddress: _addressController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.pop(context);
    }
  }
}