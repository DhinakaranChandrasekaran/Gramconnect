import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final List<Map<String, String>> filters;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) => onFilterChanged(filter['value']!),
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
            ),
          );
        }).toList(),
      ),
    );
  }
}