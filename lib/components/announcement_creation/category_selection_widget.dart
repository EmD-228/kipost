import 'package:flutter/material.dart';
import 'package:kipost/models/category.dart';

/// Widget pour la sélection de catégorie dans la création d'annonce
class CategorySelectionWidget extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelectionWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  /// Helper method to get color based on category
  Color _getCategoryColor(Category category) {
    switch (category.id) {
      case 'menuiserie':
        return Colors.brown;
      case 'plomberie':
        return Colors.blue;
      case 'electricite':
        return Colors.orange;
      case 'aide_menagere':
        return Colors.pink;
      case 'transport':
        return Colors.green;
      case 'jardinage':
        return Colors.lightGreen;
      case 'informatique':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategory == category.id;
        
        return GestureDetector(
          onTap: () => onCategorySelected(category.id),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? _getCategoryColor(category).withOpacity(0.1) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? _getCategoryColor(category) : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? _getCategoryColor(category) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    category.icon,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? _getCategoryColor(category) : Colors.grey.shade700,
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
