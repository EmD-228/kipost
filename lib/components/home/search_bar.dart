import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SearchBar extends StatelessWidget {
  final String search;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const SearchBar({
    super.key,
    required this.search,
    required this.onChanged,
    this.onClear,
    this.hintText = "Rechercher un service, une annonce...",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
       margin: const EdgeInsets.symmetric( vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 15,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Iconsax.search_normal_1,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ),
          suffixIcon: search.isNotEmpty
              ? GestureDetector(
                  onTap: onClear,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Iconsax.close_circle,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
