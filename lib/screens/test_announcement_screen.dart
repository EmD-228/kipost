import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kipost/controllers/announcement_controller.dart';
import 'package:kipost/models/announcement.dart';

class TestAnnouncementScreen extends StatefulWidget {
  @override
  _TestAnnouncementScreenState createState() => _TestAnnouncementScreenState();
}

class _TestAnnouncementScreenState extends State<TestAnnouncementScreen> {
  final AnnouncementController controller = Get.put(AnnouncementController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Announcements'),
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: controller.getAnnouncementsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final announcements = snapshot.data ?? [];

          if (announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune annonce trouvée'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Test de création d'annonce
                      controller.createAnnouncement(
                        title: 'Test Annonce',
                        description: 'Ceci est une annonce de test',
                        categoryId: 'aide_menagere',
                        urgencyLevelId: 'modere',
                        location: 'Abidjan, Côte d\'Ivoire',
                        price: 25000,
                      );
                    },
                    child: Text('Créer une annonce de test'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(announcement.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.description),
                      SizedBox(height: 4),
                      Text('Catégorie: ${announcement.category.name}'),
                      Text('Prix: ${announcement.price} FCFA'),
                      Text('Lieu: ${announcement.location}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      controller.deleteAnnouncement(announcement.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
