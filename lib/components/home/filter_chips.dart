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
  
  final List<String> statusList;
  final String selectedStatus;
  final Function(String) onStatusChanged;
  
  final List<String> dateSortList;
  final String selectedDateSort;
  final Function(String) onDateSortChanged;

  const HorizontalFilters({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.statusList,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.dateSortList,
    required this.selectedDateSort,
    required this.onDateSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Catégories
        _buildFilterSection(
          title: "Catégories",
          items: categories,
          selectedItem: selectedCategory,
          onItemSelected: onCategoryChanged,
          color: Colors.deepPurple,
        ),
        
        const SizedBox(height: 12),
        
        // Section Statut et Tri
        Row(
          children: [
            Expanded(
              child: _buildFilterSection(
                title: "Statut",
                items: statusList,
                selectedItem: selectedStatus,
                onItemSelected: onStatusChanged,
                color: Colors.green,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFilterSection(
                title: "Tri",
                items: dateSortList,
                selectedItem: selectedDateSort,
                onItemSelected: onDateSortChanged,
                color: Colors.orange,
                isCompact: true,
              ),
            ),
          ],
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          isCompact
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
        ],
      ),
    );
  }
}
