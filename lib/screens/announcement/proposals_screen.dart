import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/proposal_card.dart';
import 'package:kipost/controllers/annoncement_controller.dart';
import 'package:kipost/models/announcement.dart';
import 'package:kipost/components/kipost_button.dart';

class ProposalsScreen extends StatelessWidget {
  const ProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Announcement announcement = Get.arguments;
    final AnnouncementController controller = Get.find<AnnouncementController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Propositions reçues'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // En-tête avec les détails de l'annonce
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.document, color: Colors.deepPurple.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  announcement.description,
                  style: TextStyle(color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Liste des propositions
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: controller.getAnnouncementProposalsStream(announcement.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.document_text,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune proposition pour le moment',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Les prestataires intéressés pourront postuler',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final proposals = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: proposals.length,
                  itemBuilder: (context, index) {
                    final proposal = proposals[index];
                    return SizedBox();/* ProposalCard(
                      proposal: proposal,
                      announcement: announcement,
                      onSelect: () async {
                        final confirm = await _showConfirmDialog(
                          context,
                          proposal['userEmail'],
                        );
                        if (confirm == true) {
                          await controller.selectServiceProvider(
                            announcement.id,
                            proposal['id'],
                            proposal['userId'],
                          );
                          Get.back();
                        }
                      },
                    ); */
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String userEmail) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la sélection'),
        content: Text('Voulez-vous sélectionner $userEmail comme prestataire ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
