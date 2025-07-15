import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/controllers/announcement_controller.dart';
import 'package:kipost/controllers/auth_controller.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/models/announcement.dart';
import 'package:kipost/screens/announcement/proposals_screen.dart';
import 'package:kipost/utils/app_status.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({super.key});

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
   final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final argument = Get.arguments;

    return FutureBuilder<Announcement?>(
      future:
          argument is Announcement
              ? Future.value(argument)
              : Get.find<AnnouncementController>().getAnnouncementById(
                argument.toString(),
              ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chargement...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: const Center(child: Text('Annonce non trouvée')),
          );
        }

        final ann = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Détails de l\'annonce',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: Colors.black),
              onPressed: () => Get.back(),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              // État de l'annonce en haut
              SliverToBoxAdapter(
                child: _buildAnnouncementStatusBanner(ann),
              ),
              
              // Contenu principal
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec titre et statut
                        _buildHeader(ann),
                        const SizedBox(height: 24),

                        // Informations principales
                        _buildInfoSection(ann),
                        const SizedBox(height: 24),

                        // Description
                        _buildDescriptionSection(ann),
                        const SizedBox(height: 32),

                        // Actions utilisateur
                        ..._buildUserActions(ann),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementStatusBanner(Announcement ann) {
    final statusColors = _getStatusColors(ann.status);
    final statusIcon = _getStatusIcon(ann.status);
    final statusLabel = AnnouncementStatus.getLabel(ann.status);
    
    // Définir le message et l'icône selon le statut
    String message;
    IconData leadingIcon;
    Color backgroundColor;
    Color textColor;
    Color iconColor;
    
    switch (ann.status) {
      case AnnouncementStatus.active:
        message = 'Cette annonce est ouverte aux candidatures';
        leadingIcon = Iconsax.info_circle;
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        iconColor = Colors.green.shade600;
        break;
      case AnnouncementStatus.completed:
        message = 'Cette annonce a été terminée avec succès';
        leadingIcon = Iconsax.tick_circle;
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        iconColor = Colors.blue.shade600;
        break;
      case AnnouncementStatus.paused:
        message = 'Cette annonce est temporairement en pause';
        leadingIcon = Iconsax.pause_circle;
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        iconColor = Colors.orange.shade600;
        break;
      case AnnouncementStatus.cancelled:
        message = 'Cette annonce a été annulée';
        leadingIcon = Iconsax.close_circle;
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        iconColor = Colors.red.shade600;
        break;
      case AnnouncementStatus.expired:
        message = 'Cette annonce a expiré';
        leadingIcon = Iconsax.timer;
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade800;
        iconColor = Colors.grey.shade600;
        break;
      default:
        message = 'Statut de l\'annonce inconnu';
        leadingIcon = Iconsax.info_circle;
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade800;
        iconColor = Colors.grey.shade600;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône d'information
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              leadingIcon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Contenu textuel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Badge de statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: statusColors),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Announcement ann) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre principal
          Text(
            ann.title.capitalizeFirst!,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Statut avec badge coloré
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getStatusColors(ann.status),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColors(ann.status)[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(ann.status),
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AnnouncementStatus.getLabel(ann.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Publié le ${_formatDate(ann.createdAt)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Announcement ann) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),

          // Grille d'informations
          Column(
            children: [
              _buildInfoRow(
                icon: Iconsax.location,
                color: Colors.blue,
                label: 'Lieu',
                value: ann.location,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Iconsax.category,
                color: Colors.blue,
                label: 'Catégorie',
                value: ann.category.name,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Iconsax.user,
                color: Colors.purple,
                label: 'Créateur',
                value: ann.creatorEmail,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Announcement ann) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.document_text,
                  size: 20,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Description du projet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ann.description.capitalizeFirst!,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUserActions(Announcement ann) {
    // Check if current user is the owner using correct property names
    final isOwner =
        Get.find<AuthController>().firebaseUser.value?.uid == ann.creatorId;

    if (isOwner) {
      // Actions pour le propriétaire de l'annonce
      return [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Gérer votre annonce',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        // Bouton voir propositions (style principal)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurple.shade300],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap:
                  () => Get.to(() => const ProposalsScreen(), arguments: ann),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.document_text,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Voir les propositions',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Consultez les candidatures reçues',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Iconsax.arrow_right_3,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
         /* if (ann.status == 'ouverte') */   const SizedBox(height: 16),

        
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200, width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final confirm = await _showDeleteConfirmation();
                  if (confirm == true) {
                    await Get.find<AnnouncementController>().deleteAnnouncement(
                      ann.id,
                    );
                    Get.back();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.trash,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Supprimer l\'annonce',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Cette action est irréversible',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Iconsax.warning_2,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ];
    } else {
      // Actions pour les prestataires potentiels
      return [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Postuler à cette annonce',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        if (ann.status == AnnouncementStatus.active)
          FutureBuilder<bool>(
            future: Get.put(ProposalController()).hasUserAlreadyApplied(ann.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              final hasApplied = snapshot.data ?? false;

              if (hasApplied) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.tick_circle,
                          color: Colors.orange.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Proposition envoyée !',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vous avez déjà postulé pour cette annonce. Le créateur examinera votre proposition.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Bouton postuler avec style attractif
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.green.shade400],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showProposalDialog(ann.id),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.send_1,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Postuler maintenant',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Présentez votre candidature',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Iconsax.arrow_right_3,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.lock,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ann.status == AnnouncementStatus.completed
                            ? 'Annonce terminée'
                            : ann.status == AnnouncementStatus.cancelled
                                ? 'Annonce annulée'
                                : ann.status == AnnouncementStatus.paused
                                    ? 'Annonce en pause'
                                    : ann.status == AnnouncementStatus.expired
                                        ? 'Annonce expirée'
                                        : 'Annonce fermée',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ann.status == AnnouncementStatus.completed
                            ? 'Cette annonce a été terminée avec succès'
                            : ann.status == AnnouncementStatus.cancelled
                                ? 'Cette annonce a été annulée'
                                : ann.status == AnnouncementStatus.paused
                                    ? 'Cette annonce est temporairement en pause'
                                    : ann.status == AnnouncementStatus.expired
                                        ? 'Cette annonce a expiré'
                                        : 'Cette annonce n\'est plus disponible',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ];
    }
  }

  Future<bool?> _showDeleteConfirmation() async {
    return showDialog<bool>(
      context: Get.context!,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Iconsax.warning_2, color: Colors.red.shade600, size: 24),
                const SizedBox(width: 12),
                const Text('Confirmation'),
              ],
            ),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette annonce ? Cette action est irréversible.',
              style: TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
  }

  void _showProposalDialog(String announcementId) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: Get.context!,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.deepPurple.shade50, Colors.white],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header avec gradient
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.send_1,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Postuler pour cette annonce',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contenu
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Présentez votre candidature',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Expliquez pourquoi vous êtes la personne idéale pour ce projet :',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.grey.shade50,
                          ),
                          child: TextField(
                            controller: messageController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText:
                                  '• Décrivez votre expérience pertinente\n• Mentionnez vos compétences clés\n• Expliquez votre approche\n• Indiquez vos disponibilités',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                                height: 1.4,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Annuler',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green,
                                      Colors.green.shade400,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () async {
                                      if (messageController.text
                                          .trim()
                                          .isNotEmpty) {
                                        // Afficher un loading
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder:
                                              (ctx) => const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                        );

                                        await Get.put(
                                          ProposalController(),
                                        ).sendProposal(
                                          announcementId: announcementId,
                                          message:
                                              messageController.text.trim(),
                                        );

                                        Navigator.pop(
                                          context,
                                        ); // Fermer loading
                                        Navigator.pop(context); // Fermer dialog

                                        // Rafraîchir l'état de la page
                                        (Get.context as Element)
                                            .markNeedsBuild();

                                        // Afficher un message de succès
                                        Get.snackbar(
                                          'Succès',
                                          'Votre proposition a été envoyée !',
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                          icon: const Icon(
                                            Iconsax.tick_circle,
                                            color: Colors.white,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Iconsax.send_1,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Envoyer ma proposition',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  List<Color> _getStatusColors(String status) {
    switch (status) {
      case AnnouncementStatus.active:
        return [Colors.green, Colors.green.shade400];
      case AnnouncementStatus.completed:
        return [Colors.blue, Colors.blue.shade400];
      case AnnouncementStatus.paused:
        return [Colors.orange, Colors.orange.shade400];
      case AnnouncementStatus.cancelled:
        return [Colors.red, Colors.red.shade400];
      case AnnouncementStatus.expired:
        return [Colors.grey, Colors.grey.shade400];
      default:
        return [Colors.grey, Colors.grey.shade400];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AnnouncementStatus.active:
        return Iconsax.tick_circle;
      case AnnouncementStatus.completed:
        return Iconsax.user_tick;
      case AnnouncementStatus.paused:
        return Iconsax.pause_circle;
      case AnnouncementStatus.cancelled:
        return Iconsax.close_circle;
      case AnnouncementStatus.expired:
        return Iconsax.timer;
      default:
        return Iconsax.info_circle;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
