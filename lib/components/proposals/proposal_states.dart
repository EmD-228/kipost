import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Widget pour afficher l'état vide d'une liste de propositions
class ProposalEmptyState extends StatelessWidget {
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;
  final String emptyButtonText;
  final VoidCallback onEmptyPressed;

  const ProposalEmptyState({
    super.key,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.emptyButtonText,
    required this.onEmptyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              emptyDescription,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onEmptyPressed,
              icon: Icon(emptyIcon, size: 18),
              label: Text(emptyButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher l'état d'erreur d'une liste de propositions
class ProposalErrorState extends StatelessWidget {
  final VoidCallback onRefresh;

  const ProposalErrorState({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Impossible de charger les propositions',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

/// Widget pour afficher l'état de chargement
class ProposalLoadingState extends StatelessWidget {
  const ProposalLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
