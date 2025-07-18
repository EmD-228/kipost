import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/proposal_model.dart';
import 'package:kipost/utils/app_status.dart';

/// Widget de carte pour afficher une proposition
class ProposalCard extends StatelessWidget {
  final ProposalModel proposal;
  final void Function(ProposalModel) onTap;

  const ProposalCard({
    super.key,
    required this.proposal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap(proposal),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec email et statut
                _buildHeader(),
                const SizedBox(height: 12),

                // Titre du projet ou ID de l'annonce
                _buildAnnouncementInfo(),
                const SizedBox(height: 12),

                // Message de la proposition
                _buildMessage(),
                const SizedBox(height: 12),

                // Footer avec infos
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final providerName = proposal.provider?.fullName ?? 'Utilisateur inconnu';
    final providerInitials = proposal.provider?.initials ?? 'U';
    
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            providerInitials,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                providerName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                'ID: ${proposal.id.substring(0, 8)}...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        ProposalStatusBadge(status: proposal.status),
      ],
    );
  }

  Widget _buildAnnouncementInfo() {
    final announcement = proposal.announcement;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.briefcase,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              announcement?.title ??
                  'Annonce ID: ${proposal.announcementId.substring(0, 8)}...',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return Text(
      proposal.message,
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    final announcement = proposal.announcement;
    return Row(
      children: [
        if (announcement?.category != null && announcement!.category.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.category,
                  size: 12,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  announcement.category,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (proposal.amount != null) ...[
          Icon(
            Iconsax.money,
            size: 14,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            '${proposal.amount!.toStringAsFixed(0)} FCFA',
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
        ],
        const Spacer(),
        Icon(
          Iconsax.clock,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(proposal.createdAt),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Widget pour afficher le badge de statut d'une proposition
class ProposalStatusBadge extends StatelessWidget {
  final String status;

  const ProposalStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;
    
    switch (status) {
      case ProposalStatus.accepted:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = ProposalStatus.getLabel(status);
        icon = Iconsax.tick_circle;
        break;
      case ProposalStatus.rejected:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = ProposalStatus.getLabel(status);
        icon = Iconsax.close_circle;
        break;
      case ProposalStatus.pending:
      default:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = ProposalStatus.getLabel(status);
        icon = Iconsax.clock;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
