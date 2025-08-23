import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/complaint_provider.dart';

class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  String _selectedDistrict = '';
  String _selectedPanchayat = '';
  String _selectedVillage = '';
  String _selectedWard = '';

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
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintProvider>(
      builder: (context, complaintProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Selection
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
                
                const SizedBox(height: 24),
                
                // Location Fields
                const Text(
                  'Location Details',
                  style: AppTheme.titleMedium,
                ),
                
                const SizedBox(height: 12),
                
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'District',
                    hintText: 'Enter district name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter district';
                    }
                    return null;
                  },
                  onChanged: (value) => _selectedDistrict = value,
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Panchayat',
                    hintText: 'Enter panchayat name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter panchayat';
                    }
                    return null;
                  },
                  onChanged: (value) => _selectedPanchayat = value,
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Village',
                    hintText: 'Enter village name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter village';
                    }
                    return null;
                  },
                  onChanged: (value) => _selectedVillage = value,
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Ward',
                    hintText: 'Enter ward number/name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter ward';
                    }
                    return null;
                  },
                  onChanged: (value) => _selectedWard = value,
                ),
                
                const SizedBox(height: 24),
                
                // Description
                const Text(
                  'Problem Description',
                  style: AppTheme.titleMedium,
                ),
                
                const SizedBox(height: 12),
                
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe the problem in detail...',
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
                
                const SizedBox(height: 24),
                
                // Image Upload Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Photo (Optional)',
                          style: AppTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Take a photo to help explain the problem',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Implement camera
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Camera feature coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Implement gallery
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Gallery feature coming soon!')),
                                );
                              },
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
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
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final complaintProvider = Provider.of<ComplaintProvider>(context, listen: false);
    complaintProvider.clearError();

    final success = await complaintProvider.createComplaint(
      category: _selectedCategory!,
      description: _descriptionController.text.trim(),
      district: _selectedDistrict,
      panchayat: _selectedPanchayat,
      village: _selectedVillage,
      ward: _selectedWard,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }
}