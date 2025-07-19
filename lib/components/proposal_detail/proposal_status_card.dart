import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';

/// Widget pour afficher le statut d'une proposition
class ProposalStatusCard extends StatelessWidget {
  final ProposalModel proposal;

  const ProposalStatusCard({
    super.key,
    required this.proposal,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (proposal.status) {
      case 'pending':
        statusColor = Colors.orange.shade600;
        statusText = 'En attente';
        statusIcon = Iconsax.clock;
        break;
      case 'accepted':
        statusColor = Colors.green.shade600;
        statusText = 'Acceptée';
        statusIcon = Iconsax.tick_circle;
        break;
      case 'rejected':
        statusColor = Colors.red.shade600;
        statusText = 'Rejetée';
        statusIcon = Iconsax.close_circle;
        break;
      default:
        statusColor = Colors.grey.shade600;
        statusText = 'Statut inconnu';
        statusIcon = Iconsax.info_circle;
    }

    return Container(
      width: double.infinity,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statut de la proposition',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
