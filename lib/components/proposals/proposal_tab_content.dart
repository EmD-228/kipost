import 'package:flutter/material.dart';
import 'package:kipost/models/supabase/proposal_model.dart';
import 'package:kipost/components/proposals/proposal_card.dart';
import 'package:kipost/components/proposals/proposal_states.dart';

/// Widget générique pour afficher le contenu d'un onglet de propositions
class ProposalTabContent extends StatelessWidget {
  final int refreshKey;
  final Future<List<ProposalModel>> future;
  final String debugPrefix;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyDescription;
  final String emptyButtonText;
  final VoidCallback onEmptyPressed;
  final void Function(ProposalModel) onProposalTap;
  final VoidCallback onRefresh;

  const ProposalTabContent({
    super.key,
    required this.refreshKey,
    required this.future,
    required this.debugPrefix,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.emptyButtonText,
    required this.onEmptyPressed,
    required this.onProposalTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProposalModel>>(
      key: ValueKey(refreshKey),
      future: future,
      builder: (context, snapshot) {
        print(
          '🔍 DEBUG: $debugPrefix FutureBuilder - ConnectionState: ${snapshot.connectionState}',
        );

        // État de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ProposalLoadingState();
        }

        // État d'erreur
        if (snapshot.hasError) {
          print(
            '🔍 DEBUG: $debugPrefix FutureBuilder error: ${snapshot.error}',
          );
          return ProposalErrorState(onRefresh: onRefresh);
        }

        final proposals = snapshot.data ?? [];
        print(
          '🔍 DEBUG: $debugPrefix - Received ${proposals.length} proposals',
        );

        // État vide
        if (proposals.isEmpty) {
          return ProposalEmptyState(
            emptyIcon: emptyIcon,
            emptyTitle: emptyTitle,
            emptyDescription: emptyDescription,
            emptyButtonText: emptyButtonText,
            onEmptyPressed: onEmptyPressed,
          );
        }

        // État avec données
        return RefreshIndicator(
          onRefresh: () async {
            onRefresh();
          },
          child: Container(
            color: Colors.grey.shade50,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: proposals.length,
              itemBuilder: (context, index) {
                final proposal = proposals[index];
                return ProposalCard(
                  proposal: proposal,
                  onTap: onProposalTap,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
