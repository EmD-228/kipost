import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class StepNavigationButtons extends StatelessWidget {
  final int currentStep;
  final bool canProceed;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const StepNavigationButtons({
    super.key,
    required this.currentStep,
    required this.canProceed,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: _PreviousButton(onPressed: onPrevious),
            ),
          
          if (currentStep > 0) const SizedBox(width: 16),
          
          Expanded(
            flex: currentStep == 0 ? 1 : 1,
            child: _NextButton(
              currentStep: currentStep,
              canProceed: canProceed,
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviousButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _PreviousButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.arrow_left_2,
              color: Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Précédent',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final int currentStep;
  final bool canProceed;
  final VoidCallback? onPressed;

  const _NextButton({
    required this.currentStep,
    required this.canProceed,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: canProceed
            ? const LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: canProceed ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        boxShadow: canProceed
            ? [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: TextButton(
        onPressed: canProceed ? onPressed : null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentStep == 2 ? 'Aperçu' : 'Suivant',
              style: TextStyle(
                color: canProceed ? Colors.white : Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              currentStep == 2 ? Iconsax.eye : Iconsax.arrow_right_3,
              color: canProceed ? Colors.white : Colors.grey.shade500,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
