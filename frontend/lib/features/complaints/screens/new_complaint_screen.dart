import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import '../../../core/providers/complaint_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/complaint_model.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/category_selector.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/location_picker.dart';

class NewComplaintScreen extends StatefulWidget {
  const NewComplaintScreen({super.key});

  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  File? _selectedImage;
  String? _imageBase64;
  LocationData? _currentLocation;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {'key': 'GARBAGE', 'name': 'Garbage', 'icon': Icons.delete, 'color': AppColors.getCategoryColor('GARBAGE')},
    {'key': 'WATER_SUPPLY', 'name': 'Water Supply', 'icon': Icons.water_drop, 'color': AppColors.getCategoryColor('WATER_SUPPLY')},
    {'key': 'ELECTRICITY', 'name': 'Electricity', 'icon': Icons.electrical_services, 'color': AppColors.getCategoryColor('ELECTRICITY')},
    {'key': 'DRAINAGE', 'name': 'Drainage', 'icon': Icons.cleaning_services, 'color': AppColors.getCategoryColor('DRAINAGE')},
    {'key': 'ROAD_DAMAGE', 'name': 'Road Damage', 'icon': Icons.construction, 'color': AppColors.getCategoryColor('ROAD_DAMAGE')},
    {'key': 'HEALTH_CENTER', 'name': 'Health Center', 'icon': Icons.local_hospital, 'color': AppColors.getCategoryColor('HEALTH_CENTER')},
    {'key': 'TRANSPORT', 'name': 'Transport', 'icon': Icons.directions_bus, 'color': AppColors.getCategoryColor('TRANSPORT')},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permissions are denied');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permissions are permanently denied');
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          address: 'Current Location',
        );
        _isLoadingLocation = false;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to get location: ${e.toString()}');
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          _selectedImage = imageFile;
          _imageBase64 = base64String;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      _showErrorSnackBar('Please select a category');
      return;
    }

    if (_currentLocation == null) {
      _showErrorSnackBar('Location is required. Please enable location services.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        _showErrorSnackBar('User not found. Please login again.');
        return;
      }

      final success = await complaintProvider.createComplaint(
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        location: _currentLocation!,
        village: user.village,
        ward: user.ward,
        imageBase64: _imageBase64,
      );

      if (success) {
        _showSuccessSnackBar('Complaint submitted successfully');
        context.pop();
      } else {
        _showErrorSnackBar(complaintProvider.error ?? 'Failed to submit complaint');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
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
        title: const Text('New Complaint'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Selection
              _buildCategorySection(),

              const SizedBox(height: 24),

              // Description
              _buildDescriptionSection(),

              const SizedBox(height: 24),

              // Image Upload
              _buildImageSection(),

              const SizedBox(height: 24),

              // Location
              _buildLocationSection(),

              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['key'];

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category['key']),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? category['color'].withOpacity(0.2)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? category['color']
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      category['icon'],
                      color: isSelected
                          ? category['color']
                          : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category['name'],
                        style: TextStyle(
                          color: isSelected
                              ? category['color']
                              : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Describe the issue in detail...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a description';
            }
            if (value!.length < 10) {
              return 'Description must be at least 10 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photo (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedImage != null) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Retake'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => setState(() {
                  _selectedImage = null;
                  _imageBase64 = null;
                }),
                icon: const Icon(Icons.delete),
                label: const Text('Remove'),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
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
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: _isLoadingLocation
              ? const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Getting current location...'),
            ],
          )
              : _currentLocation != null
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text('Current Location'),
                  const Spacer(),
                  TextButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}, '
                    'Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          )
              : Column(
            children: [
              const Icon(Icons.location_off, color: Colors.red),
              const SizedBox(height: 8),
              const Text('Location not available'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('Get Location'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitComplaint,
        child: _isSubmitting
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Submit Complaint',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}