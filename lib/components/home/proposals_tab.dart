import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/models/proposal.dart';
import 'package:kipost/models/tab_config.dart';
import 'package:kipost/components/proposal_card.dart';
import 'package:kipost/components/home/tab_header.dart';
import 'package:kipost/components/home/empty_state.dart';

class ProposalsTab extends StatefulWidget {
  const ProposalsTab({super.key});

  @override
  State<ProposalsTab> createState() => _ProposalsTabState();
}

class _ProposalsTabState extends State<ProposalsTab> {
  final ProposalController proposalController = Get.put(ProposalController());

  // Configuration des onglets de propositions
  List<TabConfig> _getProposalTabs() {
    return [
      TabConfig(
        icon: Iconsax.send_1,
        label: 'Envoyées',
      ),
      TabConfig(
        icon: Iconsax.receive_square,
        label: 'Reçues',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 DEBUG: ProposalsTab build called');
    
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabHeader(
            title: 'Mes Propositions',
            icon: Iconsax.note_2,
            tabs: _getProposalTabs(),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSentProposalsTab(),
                _buildReceivedProposalsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Onglet des propositions envoyées
  Widget _buildSentProposalsTab() {
    return _buildProposalsTabContent(
      stream: proposalController.getUserProposalsStream(),
      debugPrefix: 'SentProposals',
      emptyIcon: Iconsax.send_1,
      emptyTitle: 'Aucune proposition envoyée',
      emptyDescription: 'Vous n\'avez envoyé aucune proposition\npour le moment. Explorez les annonces\net proposez vos services !',
      emptyButtonText: 'Voir les annonces',
      onEmptyPressed: () {
        // Retour à l'onglet Jobs
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      onProposalTap: (proposal) {
        Get.toNamed('/announcement-detail', arguments: proposal.announcementId);
      },
    );
  }

  // Onglet des propositions reçues
  Widget _buildReceivedProposalsTab() {
    return _buildProposalsTabContent(
      stream: proposalController.getReceivedProposalsStream(),
      debugPrefix: 'ReceivedProposals',
      emptyIcon: Iconsax.receive_square,
      emptyTitle: 'Aucune proposition reçue',
      emptyDescription: 'Vous n\'avez reçu aucune proposition\npour vos annonces. Créez une annonce\npour recevoir des propositions !',
      emptyButtonText: 'Créer une annonce',
      onEmptyPressed: () => Get.toNamed('/create-announcement'),
      onProposalTap: (proposal) => _showProposalDetailsDialog(proposal),
    );
  }

  // Méthode factorisée pour construire les onglets de propositions
  Widget _buildProposalsTabContent({
    required Stream<List<Proposal>> stream,
    required String debugPrefix,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyDescription,
    required String emptyButtonText,
    required VoidCallback onEmptyPressed,
    required void Function(Proposal) onProposalTap,
  }) {
    return StreamBuilder<List<Proposal>>(
      stream: stream,
      builder: (context, snapshot) {
        print('🔍 DEBUG: $debugPrefix StreamBuilder state: ${snapshot.connectionState}');
        print('🔍 DEBUG: $debugPrefix data length: ${snapshot.data?.length}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          print('🔍 DEBUG: $debugPrefix error: ${snapshot.error}');
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }
        
        final proposals = snapshot.data ?? [];
        
        if (proposals.isEmpty) {
          return EmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            description: emptyDescription,
            buttonText: emptyButtonText,
            onPressed: onEmptyPressed,
          );
        }
        
        return _buildProposalsList(proposals, onProposalTap);
      },
    );
  }

  // Méthode factorisée pour construire la liste des propositions
  Widget _buildProposalsList(List<Proposal> proposals, void Function(Proposal) onTap) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: proposals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final prop = proposals[i];
        return ProposalCard(
          proposal: prop,
          onTap: () => onTap(prop),
        );
      },
    );
  }

  // Dialogue pour les détails des propositions reçues
  void _showProposalDetailsDialog(Proposal proposal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Iconsax.user, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Proposition de ${proposal.userEmail}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations sur l'annonce
            if (proposal.announcement != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.briefcase, size: 16, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text(
                          'Annonce concernée',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      proposal.announcement!.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Iconsax.category, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          proposal.announcement!.category,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Iconsax.location, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            proposal.announcement!.location,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Message:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(proposal.message),
            const SizedBox(height: 16),
            Text(
              'Statut: ${proposal.status}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(proposal.status),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          if (proposal.status == 'en_attente') ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateProposalStatus(proposal.id, 'refusée');
              },
              child: const Text(
                'Refuser',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateProposalStatus(proposal.id, 'acceptée');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Accepter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Mettre à jour le statut d'une proposition
  void _updateProposalStatus(String proposalId, String newStatus) {
    proposalController.updateProposalStatus(proposalId, newStatus).then((_) {
      Get.snackbar(
        'Succès',
        'Proposition ${newStatus} avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }).catchError((error) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la mise à jour: $error',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  // Obtenir la couleur selon le statut
  Color _getStatusColor(String status) {
    switch (status) {
      case 'acceptée':
        return Colors.green;
      case 'refusée':
        return Colors.red;
      case 'en_attente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
