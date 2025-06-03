import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final String stepTitle;
  final String stepDescription;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.stepTitle,
    required this.stepDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < 3; i++) ...[
                _buildStepIndicator(i),
                if (i < 2) _buildStepConnector(i),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            stepTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stepDescription,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex) {
    final isActive = stepIndex <= currentStep;
    final isCompleted = stepIndex < currentStep;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive ? null : Colors.grey.shade200,
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Icon(
        isCompleted
            ? Iconsax.tick_circle5
            : _getStepIcon(stepIndex),
        color: isActive ? Colors.white : Colors.grey.shade500,
        size: 24,
      ),
    );
  }

  Widget _buildStepConnector(int stepIndex) {
    final isCompleted = stepIndex < currentStep;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                )
              : null,
          color: isCompleted ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Iconsax.category;
      case 1:
        return Iconsax.document_text;
      case 2:
        return Iconsax.timer_1;
      default:
        return Iconsax.info_circle;
    }
  }
}
