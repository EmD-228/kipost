import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/controllers/annoncement_controller.dart';
import 'package:kipost/models/announcement.dart';
import 'package:kipost/components/announcement_card.dart';
import 'package:kipost/components/home/search_bar.dart' as custom;
import 'package:kipost/components/home/filter_chips.dart';
import 'package:kipost/components/home/empty_state.dart';

class JobsTab extends StatefulWidget {
  const JobsTab({super.key});

  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  final AnnouncementController controller = Get.find();
  
  final List<String> _categories = [
    'Toutes', 'Menuiserie', 'Plomberie', 'Électricité', 'Aide ménagère', 'Transport', 'Autre',
  ];
  String _selectedCategory = 'Toutes';

  final List<String> _statusList = ['Tous', 'ouverte', 'fermée'];
  String _selectedStatus = 'Tous';

  final List<String> _dateSortList = ['Plus récentes', 'Plus anciennes'];
  String _selectedDateSort = 'Plus récentes';

  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barre de recherche moderne
        custom.SearchBar(
          search: _search,
          onChanged: (val) => setState(() => _search = val),
          onClear: () => setState(() => _search = ''),
        ),
        // Filtres horizontaux modernisés
        HorizontalFilters(
          categories: _categories,
          selectedCategory: _selectedCategory,
          onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
          statusList: _statusList,
          selectedStatus: _selectedStatus,
          onStatusChanged: (status) => setState(() => _selectedStatus = status),
          dateSortList: _dateSortList,
          selectedDateSort: _selectedDateSort,
          onDateSortChanged: (sort) => setState(() => _selectedDateSort = sort),
        ),
        // Liste des annonces
        Expanded(
          child: StreamBuilder(
            stream: controller.getAnnouncementsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return EmptyState(
                  icon: Iconsax.briefcase,
                  title: 'Aucune annonce disponible',
                  description: 'Soyez le premier à créer une annonce\net trouvez le service parfait !',
                  buttonText: 'Créer une annonce',
                  onPressed: () => Get.toNamed('/create-announcement'),
                );
              }
              
              // Filtrage par catégorie, statut, recherche
              var docs = snapshot.data!.docs.where((doc) {
                final catOk = _selectedCategory == 'Toutes' || doc['category'] == _selectedCategory;
                final statusOk = _selectedStatus == 'Tous' || doc['status'] == _selectedStatus;
                final searchOk = _search.isEmpty ||
                    (doc['title'] ?? '').toLowerCase().contains(_search.toLowerCase()) ||
                    (doc['description'] ?? '').toLowerCase().contains(_search.toLowerCase());
                return catOk && statusOk && searchOk;
              }).toList();

              // Conversion en objets Announcement
              final announcements = docs
                  .map((doc) => Announcement.fromMap(doc.data(), doc.id))
                  .toList();

              // Tri par date
              announcements.sort((a, b) {
                if (_selectedDateSort == 'Plus récentes') {
                  return b.createdAt.compareTo(a.createdAt);
                } else {
                  return a.createdAt.compareTo(b.createdAt);
                }
              });

              if (announcements.isEmpty) {
                return const Center(
                  child: Text('Aucune annonce pour ce filtre.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: announcements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final ann = announcements[i];
                  return AnnouncementCard(
                    announcement: ann,
                    onTap: () {
                      Get.toNamed('/announcement-detail', arguments: ann);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
