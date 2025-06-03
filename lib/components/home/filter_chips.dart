import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: Colors.deepPurple[50],
        checkmarkColor: Colors.deepPurple,
        labelStyle: TextStyle(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected 
                ? Colors.deepPurple.withOpacity(0.3)
                : Colors.grey.shade300,
          ),
        ),
        elevation: isSelected ? 2 : 0,
        pressElevation: 4,
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
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...categories.map((cat) => FilterChipWidget(
            label: cat,
            isSelected: selectedCategory == cat,
            onTap: () => onCategoryChanged(cat),
          )),
          const SizedBox(width: 12),
          ...statusList.map((status) => FilterChipWidget(
            label: status,
            isSelected: selectedStatus == status,
            onTap: () => onStatusChanged(status),
          )),
          const SizedBox(width: 12),
          ...dateSortList.map((sort) => FilterChipWidget(
            label: sort,
            isSelected: selectedDateSort == sort,
            onTap: () => onDateSortChanged(sort),
          )),
        ],
      ),
    );
  }
}
