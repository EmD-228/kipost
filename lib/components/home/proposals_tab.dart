import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/tab_config.dart';
import 'package:kipost/components/home/tab_header.dart';
import 'package:kipost/components/proposals/proposal_widgets.dart';

class ProposalsTab extends StatefulWidget {
  const ProposalsTab({super.key});

  @override
  State<ProposalsTab> createState() => _ProposalsTabState();
}

class _ProposalsTabState extends State<ProposalsTab>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  // Configuration des onglets de propositions
  List<TabConfig> _getProposalTabs() {
    return [
      TabConfig(icon: Iconsax.send_1, label: 'Envoyées'),
      TabConfig(icon: Iconsax.receive_square, label: 'Reçues'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    print('🔍 DEBUG: ProposalsTab build called');

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabHeader(
              title: 'Mes Propositions',
              icon: Iconsax.note_2,
              tabs: _getProposalTabs(),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  SentProposalsTab(),
                  ReceivedProposalsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
