import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/controllers/annoncement_controller.dart';
import 'package:kipost/controllers/auth_controller.dart';
import 'package:kipost/models/announcement.dart';

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
                // Affiche le bouton "Accepter" seulement si ce n'est PAS le créateur
                if (Get.find<AuthController>().firebaseUser.value?.uid !=
                    ann.creatorId)
                  KipostButton(
                    label: 'Accepter cette annonce',
                    icon: Iconsax.tick_circle,
                    onPressed:
                        ann.status == 'ouverte'
                            ? () => Get.find<AnnouncementController>()
                                .acceptAnnouncement(ann.id)
                            : () {},
                  ),
                const SizedBox(height: 16),
                // Affiche le bouton supprimer si c'est le créateur
                if (Get.find<AuthController>().firebaseUser.value?.uid ==
                    ann.creatorId)
                  KipostButton(
                    label: 'Supprimer',
                    icon: Iconsax.trash,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
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
                        await Get.find<AnnouncementController>().deleteAnnouncement(
                          ann.id,
                        );
                        Get.back();
                      }
                    },
                    // Optionnel : couleur différente
                    // style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
