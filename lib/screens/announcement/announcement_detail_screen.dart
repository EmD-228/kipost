import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/controllers/annoncement_controller.dart';
import 'package:kipost/controllers/auth_controller.dart';
import 'package:kipost/controllers/proposal_controller.dart';
import 'package:kipost/models/announcement.dart';
import 'package:kipost/screens/announcement/proposals_screen.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Permet de recevoir soit un Announcement (depuis Jobs), soit un id (depuis Proposals)
    final arg = Get.arguments;
    return FutureBuilder<Announcement?>(
      future: arg is Announcement ? Future.value(arg) : AnnouncementController().getAnnouncementById(arg as String),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final ann = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(ann.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Icon(
                      Iconsax.document,
                      size: 40,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Chip(
                    label: Text(
                      ann.category,
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.deepPurple.shade50,
                    avatar: const Icon(
                      Iconsax.category,
                      color: Colors.deepPurple,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  ann.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Iconsax.location,
                      size: 18,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ann.location,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Iconsax.user, size: 18, color: Colors.deepPurple),
                    const SizedBox(width: 6),
                    Text(
                      ann.creatorEmail,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(ann.description, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        ann.status,
                        style: TextStyle(
                          color:
                              ann.status == 'ouverte' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor:
                          ann.status == 'ouverte'
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                      avatar: Icon(
                        ann.status == 'ouverte'
                            ? Iconsax.tick_circle
                            : Iconsax.close_circle,
                        color: ann.status == 'ouverte' ? Colors.green : Colors.red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Créée le : ${ann.createdAt.day}/${ann.createdAt.month}/${ann.createdAt.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Actions selon le rôle de l'utilisateur
                ...(_buildUserActions(ann)),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildUserActions(Announcement ann) {
    final currentUserId = Get.find<AuthController>().firebaseUser.value?.uid;
    final isCreator = currentUserId == ann.creatorId;

    if (isCreator) {
      // Actions pour le créateur
      return [
        // Bouton voir les propositions
        if (ann.status == 'ouverte')
          KipostButton(
            label: 'Voir les propositions',
            icon: Iconsax.document_text,
            onPressed: () => Get.to(() => const ProposalsScreen(), arguments: ann),
          ),
        
        if (ann.status == 'ouverte') const SizedBox(height: 16),
        
        // Bouton supprimer
        KipostButton(
          label: 'Supprimer',
          icon: Iconsax.trash,
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: Get.context!,
              builder: (ctx) => AlertDialog(
                title: const Text('Confirmation'),
                content: const Text('Supprimer cette annonce ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await Get.find<AnnouncementController>().deleteAnnouncement(ann.id);
              Get.back();
            }
          },
        ),
      ];
    } else {
      // Actions pour les prestataires potentiels
      return [
        if (ann.status == 'ouverte')
          FutureBuilder<bool>(
            future: Get.put(ProposalController()).hasUserAlreadyApplied(ann.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final hasApplied = snapshot.data ?? false;

              if (hasApplied) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.clock, color: Colors.orange.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Proposition envoyée',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            Text(
                              'Vous avez déjà postulé pour cette annonce',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return KipostButton(
                label: 'Postuler pour cette annonce',
                icon: Iconsax.send_1,
                onPressed: () => _showProposalDialog(ann.id),
              );
            },
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Iconsax.lock, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ann.status == 'attribuée' 
                        ? 'Cette annonce a été attribuée'
                        : 'Cette annonce n\'est plus disponible',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ];
    }
  }

  void _showProposalDialog(String announcementId) {
    final TextEditingController messageController = TextEditingController();
    
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Postuler pour cette annonce'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expliquez pourquoi vous êtes la bonne personne pour ce travail :'),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Décrivez votre expérience, vos compétences...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (messageController.text.trim().isNotEmpty) {
                await Get.put(ProposalController()).sendProposal(
                  announcementId: announcementId,
                  message: messageController.text.trim(),
                );
                Navigator.pop(context);
                // Rafraîchir l'état de la page
                (Get.context as Element).markNeedsBuild();
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
  }

