import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/controllers/annoncement_controller.dart';

class AnnouncementListScreen extends StatelessWidget {
  AnnouncementListScreen({super.key});
  final AnnouncementController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Annonces')),
      body: StreamBuilder(
        stream: controller.getAnnouncementsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune annonce pour le moment.'));
          }
          final docs = snapshot.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              return ListTile(
                leading: const Icon(Iconsax.document),
                title: Text(data['title'] ?? ''),
                subtitle: Text(data['category'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Iconsax.trash, color: Colors.red),
                  onPressed: () => controller.deleteAnnouncement(docs[i].id),
                ),
                onTap: () {
                  Get.toNamed('/announcement-detail', arguments: docs[i]);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-announcement'),
        child: const Icon(Iconsax.add),
      ),
    );
  }
}