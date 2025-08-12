import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {'key': 'GARBAGE', 'name': 'Garbage', 'icon': Icons.delete},
    {'key': 'WATER_SUPPLY', 'name': 'Water Supply', 'icon': Icons.water_drop},
    {'key': 'ELECTRICITY', 'name': 'Electricity', 'icon': Icons.electrical_services},
    {'key': 'DRAINAGE', 'name': 'Drainage', 'icon': Icons.cleaning_services},
    {'key': 'ROAD_DAMAGE', 'name': 'Road Damage', 'icon': Icons.construction},
    {'key': 'HEALTH_CENTER', 'name': 'Health Center', 'icon': Icons.local_hospital},
    {'key': 'TRANSPORT', 'name': 'Transport', 'icon': Icons.directions_bus},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategory == category['key'];
        final color = AppColors.getCategoryColor(category['key']);

        return GestureDetector(
          onTap: () => onCategorySelected(category['key']),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  category['icon'],
                  color: isSelected ? color : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category['name'],
                    style: TextStyle(
                      color: isSelected ? color : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}