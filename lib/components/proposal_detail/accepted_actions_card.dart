import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';

/// Widget pour les actions disponibles lorsqu'une proposition est acceptée
class AcceptedActionsCard extends StatelessWidget {
  final ProposalModel? proposal;
  final AnnouncementModel? announcement;
  final bool isCurrentUserClient;
  final VoidCallback? onCreateContract;

  const AcceptedActionsCard({
    super.key,
    this.proposal,
    this.announcement,
    this.isCurrentUserClient = false,
    this.onCreateContract,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Iconsax.tick_circle,
                  color: Colors.green.shade600,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Proposition acceptée',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCurrentUserClient
                      ? 'Vous avez accepté cette proposition. Vous pouvez maintenant créer un contrat.'
                      : 'Cette proposition a été acceptée. Vous pouvez maintenant contacter le client.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Bouton pour créer un contrat (seulement pour le client)
          if (isCurrentUserClient && proposal != null && announcement != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreateContract,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Iconsax.document),
                label: const Text(
                  'Créer un contrat',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
