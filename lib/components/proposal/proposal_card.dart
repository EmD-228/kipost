import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/proposal.dart';
import 'package:kipost/utils/app_status.dart';

class ProposalCard extends StatelessWidget {
  final Proposal proposal;
  final String? announcementCreatorEmail;
  final bool isCurrentUserSender;

  const ProposalCard({
    super.key,
    required this.proposal,
    this.announcementCreatorEmail,
    this.isCurrentUserSender = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  _getDisplayInitial(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                    fontSize: 18
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayName(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDisplaySubtitle(),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(proposal.status),
            ],
          ),
        ],
      ),
    );
  }

  String _getDisplayInitial() {
    if (isCurrentUserSender && announcementCreatorEmail != null && announcementCreatorEmail!.isNotEmpty) {
      return announcementCreatorEmail!.substring(0, 1).toUpperCase();
    }
    return proposal.userEmail.isNotEmpty
        ? proposal.userEmail.substring(0, 1).toUpperCase()
        : 'U';
  }

  String _getDisplayName() {
    if (isCurrentUserSender && announcementCreatorEmail != null && announcementCreatorEmail!.isNotEmpty) {
      return announcementCreatorEmail!;
    }
    return proposal.userEmail;
  }

  String _getDisplaySubtitle() {
    if (isCurrentUserSender) {
      return 'Client • ${_formatDate(proposal.createdAt)}';
    }
    return 'Proposition • ${_formatDate(proposal.createdAt)}';
  }

  Widget _buildStatusBadge(String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
