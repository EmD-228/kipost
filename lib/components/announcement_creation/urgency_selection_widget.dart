import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/urgency_level.dart';

/// Widget pour la sélection du niveau d'urgence dans la création d'annonce
class UrgencySelectionWidget extends StatelessWidget {
  final List<UrgencyLevel> urgencyLevels;
  final String? selectedUrgency;
  final Function(String) onUrgencySelected;

  const UrgencySelectionWidget({
    super.key,
    required this.urgencyLevels,
    required this.selectedUrgency,
    required this.onUrgencySelected,
  });

  /// Helper method to get color based on urgency level
  Color _getUrgencyColor(UrgencyLevel urgency) {
    if (urgency.isUrgent) return Colors.red;
    if (urgency.isModerate) return Colors.orange;
    return Colors.green;
  }

  /// Helper method to get icon based on urgency level
  IconData _getUrgencyIcon(UrgencyLevel urgency) {
    if (urgency.isUrgent) return Iconsax.danger;
    if (urgency.isModerate) return Iconsax.timer_1;
    return Iconsax.clock;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: urgencyLevels.length,
      itemBuilder: (context, index) {
        final urgency = urgencyLevels[index];
        final isSelected = selectedUrgency == urgency.id;
        final urgencyColor = _getUrgencyColor(urgency);
        final urgencyIcon = _getUrgencyIcon(urgency);
        
        return GestureDetector(
          onTap: () => onUrgencySelected(urgency.id),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? urgencyColor.withOpacity(0.1) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? urgencyColor : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? urgencyColor : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    urgencyIcon,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    urgency.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? urgencyColor : Colors.grey.shade700,
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
