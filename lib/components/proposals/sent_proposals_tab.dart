import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/services/proposal_service.dart';
import 'package:kipost/components/proposals/proposal_widgets.dart';

/// Onglet des propositions envoyées
class SentProposalsTab extends StatefulWidget {
  final ProposalService? proposalService;
  
  const SentProposalsTab({
    super.key,
    this.proposalService,
  });

  @override
  State<SentProposalsTab> createState() => _SentProposalsTabState();
}

class _SentProposalsTabState extends State<SentProposalsTab> {
  late final ProposalService _proposalService;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _proposalService = widget.proposalService ?? ProposalService();
  }

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProposalTabContent(
      refreshKey: _refreshKey,
      future: _proposalService.getProviderProposals(),
      debugPrefix: 'SentProposals',
      emptyIcon: Iconsax.send_1,
      emptyTitle: 'Aucune proposition envoyée',
      emptyDescription:
          'Vous n\'avez envoyé aucune proposition\npour le moment. Explorez les annonces\net proposez vos services !',
      emptyButtonText: 'Voir les annonces',
      onEmptyPressed: () {
        // Retour à l'onglet Jobs
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      onProposalTap: (proposal) {
        Get.toNamed('/proposal-detail', arguments: proposal);
      },
      onRefresh: _refresh,
    );
  }
}
