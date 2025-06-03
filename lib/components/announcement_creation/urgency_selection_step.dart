import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UrgencyLevelCard extends StatelessWidget {
  final Map<String, dynamic> urgency;
  final bool isSelected;
  final VoidCallback onTap;
  final AnimationController animationController;

  const UrgencyLevelCard({
    super.key,
    required this.urgency,
    required this.isSelected,
    required this.onTap,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          onTap();
          animationController.reset();
          animationController.forward();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? urgency['color'].withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? urgency['color'] : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? urgency['color'].withOpacity(0.2)
                    : Colors.black.withOpacity(0.04),
                blurRadius: isSelected ? 12 : 6,
                offset: Offset(0, isSelected ? 6 : 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: urgency['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  urgency['icon'],
                  color: urgency['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      urgency['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? urgency['color'] : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      urgency['desc'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Iconsax.tick_circle5,
                  color: urgency['color'],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class UrgencySelectionStep extends StatelessWidget {
  final List<Map<String, dynamic>> urgencyLevels;
  final String? selectedUrgency;
  final ValueChanged<String> onUrgencySelected;
  final AnimationController animationController;

  const UrgencySelectionStep({
    super.key,
    required this.urgencyLevels,
    required this.selectedUrgency,
    required this.onUrgencySelected,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          Text(
            'Quelle est l\'urgence de votre demande ?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: urgencyLevels.length,
            itemBuilder: (context, index) {
              final urgency = urgencyLevels[index];
              final isSelected = selectedUrgency == urgency['name'];
              
              return UrgencyLevelCard(
                urgency: urgency,
                isSelected: isSelected,
                animationController: animationController,
                onTap: () => onUrgencySelected(urgency['name']),
              );
            },
          ),
        ],
      ),
    );
  }
}
