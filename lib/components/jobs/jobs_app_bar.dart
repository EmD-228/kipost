import 'package:flutter/material.dart';
import 'package:kipost/models/category.dart';
import 'package:kipost/components/home/search_bar.dart' as custom;
import 'package:kipost/components/home/filter_chips.dart';

class JobsAppBar extends StatelessWidget {
  final String search;
  final List<Category> categories;
  final String selectedCategoryId;
  final Function(String) onSearchChanged;
  final Function(String) onCategoryChanged;

  const JobsAppBar({
    super.key,
    required this.search,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSearchChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.grey.shade50,
      expandedHeight: 145.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 5,
          ),
          child: Column(
            children: [
              custom.SearchBar(
                search: search,
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: 8),
              HorizontalFilters(
                categories: categories.map((cat) => cat.name).toList(),
                selectedCategory: categories
                    .firstWhere(
                      (cat) => cat.id == selectedCategoryId,
                    )
                    .name,
                onCategoryChanged: onCategoryChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
