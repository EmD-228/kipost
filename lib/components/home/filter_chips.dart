import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.deepPurple;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? chipColor : Colors.grey.shade700,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class HorizontalFilters extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const HorizontalFilters({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFilterSection(
      title: "Catégories",
      items: categories,
      selectedItem: selectedCategory,
      onItemSelected: onCategoryChanged,
      color: Colors.deepPurple,
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required String selectedItem,
    required Function(String) onItemSelected,
    required Color color,
    bool isCompact = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: isCompact
          ? Wrap(
              spacing: 8,
              children: items.map((item) => FilterChipWidget(
                label: item,
                isSelected: selectedItem == item,
                onTap: () => onItemSelected(item),
                color: color,
              )).toList(),
            )
          : SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: items.map((item) => FilterChipWidget(
                  label: item,
                  isSelected: selectedItem == item,
                  onTap: () => onItemSelected(item),
                  color: color,
                )).toList(),
              ),
            ),
    );
  }
}
