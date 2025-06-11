import 'package:flutter/material.dart';

// Nhiều lựa chọn cho mỗi lần
class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Helper to get color with alpha using doubles (for Flutter 3.19+)
    Color withAlphaDouble(Color color, double alphaFactor) {
      // Clamp to [0,1]
      final clamped = alphaFactor.clamp(0.0, 1.0);
      return color.withAlpha((255 * clamped).round());
    }

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedFilter == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onFilterSelected(category);
                }
              },
              selectedColor: withAlphaDouble(primaryColor, 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? primaryColor
                    : isDarkMode ? Colors.grey[300] : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: isDarkMode ? Colors.white : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? primaryColor
                      : withAlphaDouble(Colors.grey, 0.3),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}