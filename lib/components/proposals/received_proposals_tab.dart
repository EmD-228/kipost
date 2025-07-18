import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/services/proposal_service.dart';
import 'package:kipost/components/proposals/proposal_widgets.dart';

/// Onglet des propositions reçues
class ReceivedProposalsTab extends StatefulWidget {
  final ProposalService? proposalService;
  
  const ReceivedProposalsTab({
    super.key,
    this.proposalService,
  });

  @override
  State<ReceivedProposalsTab> createState() => _ReceivedProposalsTabState();
}

class _ReceivedProposalsTabState extends State<ReceivedProposalsTab> {
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
      future: _proposalService.getClientProposals(),
      debugPrefix: 'ReceivedProposals',
      emptyIcon: Iconsax.receive_square,
      emptyTitle: 'Aucune proposition reçue',
      emptyDescription:
          'Vous n\'avez reçu aucune proposition\npour vos annonces. Créez une annonce\npour recevoir des propositions !',
      emptyButtonText: 'Créer une annonce',
      onEmptyPressed: () => Get.toNamed('/create-announcement'),
      onProposalTap: (proposal) {
        Get.toNamed('/proposal-detail', arguments: proposal);
      },
      onRefresh: _refresh,
    );
  }
}
