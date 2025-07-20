import 'package:flutter/material.dart';
import 'package:kipost/theme/app_colors.dart';
import 'package:kipost/components/text/app_text.dart';
import 'package:kipost/components/proposals/proposal_widgets.dart';

class ProposalsTab extends StatefulWidget {
  const ProposalsTab({super.key});

  @override
  State<ProposalsTab> createState() => _ProposalsTabState();
}

class _ProposalsTabState extends State<ProposalsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.heading2(
                  'Mes Propositions',
                  color: AppColors.onSurface,
                ),
                const SizedBox(height: 8),
                AppText.body(
                  'Suivez vos propositions envoyées et reçues',
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: 'Envoyées'),
                Tab(text: 'Reçues'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                SentProposalsTab(),
                ReceivedProposalsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
