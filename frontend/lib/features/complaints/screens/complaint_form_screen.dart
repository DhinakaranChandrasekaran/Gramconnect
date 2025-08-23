import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/complaint_provider.dart';
import '../../../core/services/location_service.dart';

class ComplaintFormScreen extends StatefulWidget {
  const ComplaintFormScreen({super.key});

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedDistrict;
  String? _selectedPanchayat;
  String? _selectedVillage;
  String? _selectedWard;

  File? _selectedImage;
  Position? _currentLocation;
  bool _isLoadingLocation = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'GARBAGE', 'label': 'Garbage Collection', 'icon': Icons.delete_outline},
    {'value': 'WATER', 'label': 'Water Supply', 'icon': Icons.water_drop_outlined},
    {'value': 'ELECTRICITY', 'label': 'Electricity', 'icon': Icons.electrical_services_outlined},
    {'value': 'DRAINAGE', 'label': 'Drainage', 'icon': Icons.settings_input_component_outlined},
    {'value': 'ROAD_DAMAGE', 'label': 'Road Damage', 'icon': Icons.construction_outlined},
    {'value': 'HEALTH', 'label': 'Health Services', 'icon': Icons.local_hospital_outlined},
    {'value': 'TRANSPORT', 'label': 'Transportation', 'icon': Icons.directions_bus_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('New Complaint'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category Selection Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Category',
                            style: AppTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 2.5,
                            ),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected = _selectedCategory == category['value'];

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category['value'];
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: isSelected
                                        ? AppTheme.primaryColor.withOpacity(0.1)
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        category['icon'],
                                        size: 20,
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          category['label'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            color: isSelected
                                                ? AppTheme.primaryColor
                                                : AppTheme.textSecondary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title Field Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Complaint Title',
                          hintText: 'Brief title for your complaint',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.title_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Field Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe the problem in detail...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.description_outlined),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe the problem';
                          }
                          if (value.length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Section Card
                  _buildLocationSection(),

                  const SizedBox(height: 16),

                  // Photo Section Card
                  _buildPhotoSection(),

                  const SizedBox(height: 16),

                  // Live GPS Location Card
                  _buildLiveLocationSection(),

                  const SizedBox(height: 24),

                  // Error Message
                  if (complaintProvider.error != null)
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
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              complaintProvider.error!,
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Submit Button
                  ElevatedButton(
                    onPressed: complaintProvider.isLoading
                        ? null
                        : _handleSubmit,
                    child: complaintProvider.isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Submit Complaint'),
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

  Widget _buildLocationSection() {
    return Card(
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
                border: OutlineInputBorder(),
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
                border: OutlineInputBorder(),
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
                border: OutlineInputBorder(),
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
                border: OutlineInputBorder(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Photo (Optional)',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            if (_selectedImage != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take a photo to help explain the problem',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live GPS Location',
              style: AppTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            if (_currentLocation != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Live location captured',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Latitude: ${_currentLocation!.latitude.toStringAsFixed(6)}',
                      style: AppTheme.bodySmall,
                    ),
                    Text(
                      'Longitude: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                      style: AppTheme.bodySmall,
                    ),
                    Text(
                      'Accuracy: ${_currentLocation!.accuracy.toStringAsFixed(1)}m',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_off,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Live location not captured',
                        style: AppTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.my_location),
                label: Text(_isLoadingLocation ? 'Getting Live Location...' : 'Capture Live Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Note: Live location is required for complaint registration',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textTertiary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable location services.');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable in settings.');
      }

      // Get current position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      setState(() {
        _currentLocation = position;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live location captured successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture live location before submitting'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    complaintProvider.clearError();

    final success = await complaintProvider.createComplaint(
      category: _selectedCategory!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      district: _selectedDistrict!,
      panchayat: _selectedPanchayat!,
      village: _selectedVillage!,
      ward: _selectedWard!,
      lat: _currentLocation!.latitude,
      lng: _currentLocation!.longitude,
      imagePath: _selectedImage?.path,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint submitted successfully!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      Navigator.pop(context);
    }
  }
}