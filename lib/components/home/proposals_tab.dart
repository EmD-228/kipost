import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/models/proposal.dart';
import 'package:kipost/models/tab_config.dart';
import 'package:kipost/components/home/tab_header.dart';

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

  // Méthode factorisée pour construire les onglets de propositions avec design simple
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
    // Données fictives pour le design
    List<Map<String, dynamic>> fakeProposals = [
      {
        'id': '1',
        'title': 'Développement application mobile',
        'userEmail': 'john.doe@email.com',
        'userName': 'John Doe',
        'message': 'Je suis développeur Flutter avec 3 ans d\'expérience. Je peux réaliser votre projet dans les délais.',
        'status': 'en_attente',
        'date': 'Il y a 2 heures',
        'category': 'Développement',
        'budget': '150 000 FCFA',
      },
      {
        'id': '2',
        'title': 'Design logo et identité visuelle',
        'userEmail': 'marie.martin@email.com',
        'userName': 'Marie Martin',
        'message': 'Designer graphique passionnée, je propose un design moderne et professionnel pour votre marque.',
        'status': 'acceptée',
        'date': 'Hier',
        'category': 'Design',
        'budget': '75 000 FCFA',
      },
      {
        'id': '3',
        'title': 'Rédaction contenu web',
        'userEmail': 'paul.dupont@email.com',
        'userName': 'Paul Dupont',
        'message': 'Rédacteur web SEO, je peux créer du contenu optimisé pour votre site internet.',
        'status': 'refusée',
        'date': 'Il y a 3 jours',
        'category': 'Rédaction',
        'budget': '50 000 FCFA',
      },
      {
        'id': '4',
        'title': 'Création site e-commerce',
        'userEmail': 'sophie.blanc@email.com',
        'userName': 'Sophie Blanc',
        'message': 'Développeuse web spécialisée e-commerce. Portfolio disponible sur demande.',
        'status': 'en_attente',
        'date': 'Il y a 1 semaine',
        'category': 'Web',
        'budget': '200 000 FCFA',
      },
    ];

    return Container(
      color: Colors.grey.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fakeProposals.length,
        itemBuilder: (context, index) {
          final proposal = fakeProposals[index];
          return _buildSimpleProposalCard(proposal, onProposalTap);
        },
      ),
    );
  }

  // Card simple pour les propositions
  Widget _buildSimpleProposalCard(Map<String, dynamic> proposal, void Function(Proposal) onTap) {
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
          onTap: () {
            // Simulation d'un tap - ici on peut montrer un dialog
            _showSimpleProposalDialog(proposal);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec nom et statut
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        proposal['userName'].toString().substring(0, 1).toUpperCase(),
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
                            proposal['userName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            proposal['userEmail'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(proposal['status']),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Titre du projet
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
                          proposal['title'],
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
                  proposal['message'],
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        proposal['category'],
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Iconsax.money,
                      size: 14,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      proposal['budget'],
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Iconsax.clock,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      proposal['date'],
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

  // Dialog simple pour afficher les détails
  void _showSimpleProposalDialog(Map<String, dynamic> proposal) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      proposal['userName'].toString().substring(0, 1).toUpperCase(),
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
                          proposal['userName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          proposal['userEmail'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(proposal['status']),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Projet
              Text(
                'Projet : ${proposal['title']}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  proposal['message'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Infos complémentaires
              Row(
                children: [
                  Text(
                    'Budget : ${proposal['budget']}',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    proposal['date'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ),
                  if (proposal['status'] == 'en_attente') ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Get.snackbar(
                            'Action simulée',
                            'Proposition acceptée (simulation)',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accepter'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
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
                        Icon(proposal.announcement!.category.icon, size: 12, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          proposal.announcement!.category.name,
                          style: TextStyle(
                            color: Colors.blue,
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
                _acceptProposal(proposal);
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

  // Accepter une proposition et rediriger vers la page de planification
  void _acceptProposal(Proposal proposal) {
    // Rediriger vers la page de planification intégrée
    Get.toNamed('/proposal-accepted', arguments: proposal);
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
