import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/theme/app_colors.dart';
import 'package:kipost/components/text/app_text.dart';

class ContractsTab extends StatefulWidget {
  const ContractsTab({super.key});

  @override
  State<ContractsTab> createState() => _ContractsTabState();
}

class _ContractsTabState extends State<ContractsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                  'Mes Contrats',
                  color: AppColors.onSurface,
                ),
                const SizedBox(height: 8),
                AppText.body(
                  'Gérez vos contrats en cours et historique',
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
                Tab(text: 'En cours'),
                Tab(text: 'Terminés'),
                Tab(text: 'Annulés'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveContracts(),
                _buildCompletedContracts(),
                _buildCancelledContracts(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveContracts() {
    return Container(
      color: const Color(0xFFF8F9FF),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TODO: Replace with real data
          _buildContractCard(
            title: 'Développement App Mobile',
            client: 'Jean Dupont',
            amount: 2500.0,
            status: 'En cours',
            progress: 0.65,
            statusColor: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildContractCard(
            title: 'Site Web E-commerce',
            client: 'Marie Martin',
            amount: 1800.0,
            status: 'En cours',
            progress: 0.30,
            statusColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedContracts() {
    return Container(
      color: const Color(0xFFF8F9FF),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildContractCard(
            title: 'Logo Design',
            client: 'Paul Bernard',
            amount: 350.0,
            status: 'Terminé',
            progress: 1.0,
            statusColor: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildContractCard(
            title: 'Refonte Site Vitrine',
            client: 'Sophie Leroy',
            amount: 1200.0,
            status: 'Terminé',
            progress: 1.0,
            statusColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledContracts() {
    return Container(
      color: const Color(0xFFF8F9FF),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildContractCard(
            title: 'Application de Gestion',
            client: 'Lucas Moreau',
            amount: 3200.0,
            status: 'Annulé',
            progress: 0.0,
            statusColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildContractCard({
    required String title,
    required String client,
    required double amount,
    required String status,
    required double progress,
    required Color statusColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Expanded(
                  child: AppText.heading3(
                    title,
                    color: AppColors.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AppText.caption(
                    status,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Client info
            Row(
              children: [
                Icon(
                  Iconsax.user,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                AppText.body(
                  client,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Amount
            Row(
              children: [
                Icon(
                  Iconsax.money_2,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                AppText.body(
                  '${amount.toInt()}€',
                  color: AppColors.primary,
                ),
              ],
            ),
            
            // Progress bar (only for active contracts)
            if (status == 'En cours') ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.caption(
                        'Progression',
                        color: AppColors.onSurfaceVariant,
                      ),
                      AppText.caption(
                        '${(progress * 100).toInt()}%',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Voir les détails du contrat
                    },
                    icon: const Icon(Iconsax.eye, size: 18),
                    label: const Text('Détails'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (status == 'En cours')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Gérer le contrat
                      },
                      icon: const Icon(Iconsax.edit, size: 18),
                      label: const Text('Gérer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
