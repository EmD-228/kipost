import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/models/proposal.dart';
import 'package:kipost/models/announcement.dart';
import 'package:kipost/models/tab_config.dart';
import 'package:kipost/components/home/tab_header.dart';

class ProposalsTab extends StatefulWidget {
  const ProposalsTab({super.key});

  @override
  State<ProposalsTab> createState() => _ProposalsTabState();
}

class _ProposalsTabState extends State<ProposalsTab> with AutomaticKeepAliveClientMixin {
  final ProposalController proposalController = Get.put(ProposalController());
  
  @override
  bool get wantKeepAlive => true;
  
  // Clés pour forcer le rafraîchissement
  int _sentProposalsKey = 0;
  int _receivedProposalsKey = 0;

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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
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
      key: _sentProposalsKey,
      future: proposalController.getUserProposals(),
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
        Get.toNamed('/proposal-detail', arguments: proposal);
      },
      onRefresh: () {
        setState(() {
          _sentProposalsKey++;
        });
      },
    );
  }

  // Onglet des propositions reçues
  Widget _buildReceivedProposalsTab() {
    return _buildProposalsTabContent(
      key: _receivedProposalsKey,
      future: proposalController.getReceivedProposals(),
      debugPrefix: 'ReceivedProposals',
      emptyIcon: Iconsax.receive_square,
      emptyTitle: 'Aucune proposition reçue',
      emptyDescription: 'Vous n\'avez reçu aucune proposition\npour vos annonces. Créez une annonce\npour recevoir des propositions !',
      emptyButtonText: 'Créer une annonce',
      onEmptyPressed: () => Get.toNamed('/create-announcement'),
      onProposalTap: (proposal) {
        Get.toNamed('/proposal-detail', arguments: proposal);
      },
      onRefresh: () {
        setState(() {
          _receivedProposalsKey++;
        });
      },
    );
  }

  // Méthode factorisée pour construire les onglets de propositions avec design simple
  Widget _buildProposalsTabContent({
    required int key,
    required Future<List<Proposal>> future,
    required String debugPrefix,
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyDescription,
    required String emptyButtonText,
    required VoidCallback onEmptyPressed,
    required void Function(Proposal) onProposalTap,
    required VoidCallback onRefresh,
  }) {
    return FutureBuilder<List<Proposal>>(
      key: ValueKey(key),
      future: future,
      builder: (context, snapshot) {
        print('🔍 DEBUG: $debugPrefix FutureBuilder - ConnectionState: ${snapshot.connectionState}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.hasError) {
          print('🔍 DEBUG: $debugPrefix FutureBuilder error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.warning_2,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Impossible de charger les propositions',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRefresh,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }
        
        final proposals = snapshot.data ?? [];
        print('🔍 DEBUG: $debugPrefix - Received ${proposals.length} proposals');
        
        if (proposals.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    emptyIcon,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emptyDescription,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onEmptyPressed,
                    icon: Icon(emptyIcon, size: 18),
                    label: Text(emptyButtonText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
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
                return _buildRealProposalCard(proposal, onProposalTap);
              },
            ),
          ),
        );
      },
    );
  }

  // Card pour les propositions réelles
  Widget _buildRealProposalCard(Proposal proposal, void Function(Proposal) onTap) {
    return FutureBuilder<Announcement?>(
      future: proposalController.getAnnouncementForProposal(proposal.announcementId),
      builder: (context, announcementSnapshot) {
        final announcement = announcementSnapshot.data;
        
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            proposal.userEmail.isNotEmpty 
                                ? proposal.userEmail.substring(0, 1).toUpperCase()
                                : 'U',
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
                                proposal.userEmail,
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
                        _buildStatusBadge(proposal.status),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Titre du projet ou ID de l'annonce
                    Container(
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
                              announcement?.title ?? 'Annonce ID: ${proposal.announcementId.substring(0, 8)}...',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Message de la proposition
                    Text(
                      proposal.message,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Footer avec infos
                    Row(
                      children: [
                        if (announcement?.category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  announcement!.category.icon,
                                  size: 12,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  announcement.category.name,
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
                        if (announcement?.price != null) ...[
                          Icon(
                            Iconsax.money,
                            size: 14,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${announcement!.price} FCFA',
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to format dates
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

  // Badge de statut simple
  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'acceptée':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        label = 'Acceptée';
        icon = Iconsax.tick_circle;
        break;
      case 'refusée':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        label = 'Refusée';
        icon = Iconsax.close_circle;
        break;
      case 'en_attente':
      default:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        label = 'En attente';
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
          Icon(
            icon,
            size: 12,
            color: textColor,
          ),
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
