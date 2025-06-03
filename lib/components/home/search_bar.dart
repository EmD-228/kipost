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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(Iconsax.search_normal, color: Colors.deepPurple, size: 20),
            ),
            suffixIcon: search.isNotEmpty
                ? IconButton(
                    icon: Icon(Iconsax.close_circle, color: Colors.grey.shade400),
                    onPressed: onClear,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.3), width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
