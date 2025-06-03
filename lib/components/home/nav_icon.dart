import 'package:flutter/material.dart';

class NavIcon extends StatelessWidget {
  final IconData icon;
  final int index;
  final int selectedIndex;

  const NavIcon({
    super.key,
    required this.icon,
    required this.index,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
      ),
    );
  }
}
