import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/models/proposal.dart';

class ActionButtonsSection extends StatelessWidget {
  final Proposal proposal;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;
  final VoidCallback? onContact;
  final bool isLoading;

  const ActionButtonsSection({
    super.key,
    required this.proposal,
    this.onAccept,
    this.onReject,
    this.onComplete,
    this.onContact,
    this.isLoading = false,
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
          Text(
            'Actions',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),

          if (proposal.status == 'pending') ...[
            _buildPendingActions(),
          ] else if (proposal.status == 'accepted') ...[
            _buildAcceptedActions(),
          ] else if (proposal.status == 'completed') ...[
            _buildCompletedActions(),
          ] else if (proposal.status == 'rejected') ...[
            _buildRejectedActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onReject,
                icon: Icon(Iconsax.close_circle, size: 18),
                label: const Text('Refuser'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.red.shade300),
                  foregroundColor: Colors.red.shade600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KipostButton(
                label: 'Accepter',
                onPressed: isLoading ? null : onAccept,
                icon: Iconsax.tick_circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onContact,
            icon: Icon(Iconsax.message, size: 18),
            label: const Text('Contacter le proposant'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blue.shade300),
              foregroundColor: Colors.blue.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptedActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: KipostButton(
            label: 'Marquer comme terminé',
            onPressed: isLoading ? null : onComplete,
            icon: Iconsax.tick_circle,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onContact,
            icon: Icon(Iconsax.message, size: 18),
            label: const Text('Contacter le proposant'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blue.shade300),
              foregroundColor: Colors.blue.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedActions() {
    return Container(
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
            'Travail terminé',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ce travail a été marqué comme terminé',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onContact,
              icon: Icon(Iconsax.message, size: 18),
              label: const Text('Contacter le proposant'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.green.shade300),
                foregroundColor: Colors.green.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.close_circle,
            color: Colors.red.shade600,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Proposition refusée',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cette proposition a été refusée',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
