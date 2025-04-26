import 'package:flutter/material.dart';

class CategorySelectionBar extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  const CategorySelectionBar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Theme(
              // Override the checkmark color for dark mode
              data: Theme.of(context).copyWith(
                checkboxTheme: CheckboxThemeData(
                  checkColor: WidgetStateProperty.all(
                    isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              child: ChoiceChip(
                label: Text(categories[index]),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onCategorySelected(index);
                  }
                },
                selectedColor: primaryColor.withAlpha(50),
                labelStyle: TextStyle(
                  color: isSelected
                      ? primaryColor
                      : isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? primaryColor
                        : Colors.grey.withAlpha(80),
                  ),
                ),
                backgroundColor: Colors.transparent,
                // Explicitly set the check mark color for dark mode
                checkmarkColor: isDarkMode ? Colors.white : null,
              ),
            ),
          );
        },
      ),
    );
  }
}