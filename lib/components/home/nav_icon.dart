import 'package:flutter/material.dart';
import 'package:kipost/theme/app_colors.dart';

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
        color: isSelected ?AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isSelected ? AppColors.onPrimaryContainer : Colors.grey.shade400,
      ),
    );
  }
}
