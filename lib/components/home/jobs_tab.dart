import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/models/announcement.dart';
import 'package:kipost/components/home/search_bar.dart' as custom;
import 'package:kipost/components/home/filter_chips.dart';

class JobsTab extends StatefulWidget {
  const JobsTab({super.key});

  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  final List<String> _categories = [
    'Toutes',
    'Menuiserie',
    'Plomberie',
    'Électricité',
    'Aide ménagère',
    'Transport',
    'Autre',
  ];
  String _selectedCategory = 'Toutes';

  String _search = '';

  // Données fictives pour le développement utilisant le nouveau modèle
  final List<Announcement> _mockAnnouncements = [
    Announcement.createMockAnnouncement(
      id: '1',
      title: 'Réparation de plomberie urgente',
      description: 'Recherche plombier qualifié pour réparer une fuite d\'eau dans la cuisine. Intervention rapide souhaitée.',
      categoryId: 'plomberie',
      status: 'open',
      location: 'Cocody, Abidjan',
      budget: '25000',
      creatorName: 'Kofi Asante',
      creatorAvatar: 'https://avatar.iran.liara.run/public/42',
      proposalCount: 3,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Announcement.createMockAnnouncement(
      id: '2',
      title: 'Installation électrique complète',
      description: 'Installation électrique pour un nouveau bureau. Recherche électricien certifié avec expérience.',
      categoryId: 'electricite',
      status: 'open',
      location: 'Plateau, Abidjan',
      budget: '150000',
      creatorName: 'Ama Serwaa',
      creatorAvatar: 'https://avatar.iran.liara.run/public/25',
      proposalCount: 7,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Announcement.createMockAnnouncement(
      id: '3',
      title: 'Service de ménage hebdomadaire',
      description: 'Recherche aide ménagère fiable pour entretien hebdomadaire d\'un appartement 3 pièces.',
      categoryId: 'aide_menagere',
      status: 'open',
      location: 'Yopougon, Abidjan',
      budget: '40000',
      creatorName: 'Akosua Gyasi',
      creatorAvatar: 'https://avatar.iran.liara.run/public/33',
      proposalCount: 12,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Announcement.createMockAnnouncement(
      id: '4',
      title: 'Transport de déménagement',
      description: 'Besoin d\'un service de transport pour déménagement complet d\'un appartement 2 pièces.',
      categoryId: 'transport',
      status: 'open',
      location: 'Adjamé, Abidjan',
      budget: '60000',
      creatorName: 'Yaw Mensah',
      creatorAvatar: 'https://avatar.iran.liara.run/public/18',
      proposalCount: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<Announcement> get _filteredAnnouncements {
    return _mockAnnouncements.where((announcement) {
        final categoryMatch =
            _selectedCategory == 'Toutes' ||
            announcement.category.name == _selectedCategory;
        final searchMatch =
            _search.isEmpty ||
            announcement.title.toLowerCase().contains(
              _search.toLowerCase(),
            ) ||
            announcement.description.toLowerCase().contains(
              _search.toLowerCase(),
            ) ||
            announcement.location.toLowerCase().contains(
              _search.toLowerCase(),
            );

        return categoryMatch && searchMatch;
      }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAnnouncements = _filteredAnnouncements;

    return CustomScrollView(
      slivers: [
        // SliverAppBar avec barre de recherche et filtres dans flexibleSpace
        SliverAppBar(
          expandedHeight: 145.0,
          floating: true,
          snap: true,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: Colors.white,
              // padding: const EdgeInsets.fromLTRB(16,0, 16, 16),
              child: Column(
                children: [
                  // Barre de recherche moderne
                  custom.SearchBar(
                    search: _search,
                    onChanged: (val) => setState(() => _search = val),
                    onClear: () => setState(() => _search = ''),
                  ),
                  
                   const SizedBox(height: 6),
                  
                  // Filtres horizontaux modernisés
                  HorizontalFilters(
                    
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Liste des annonces avec effet sliver
        filteredAnnouncements.isEmpty
            ? SliverFillRemaining(
                child: _buildEmptyState(),
              )
            : SliverPadding(
                padding: EdgeInsets.zero,
                sliver: SliverList.separated(
                  itemCount: filteredAnnouncements.length,
                  itemBuilder: (context, index) {
                    final announcement = filteredAnnouncements[index];
                    return _buildAnnouncementCard(announcement);
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.briefcase, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune annonce trouvée',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres\nou créez une nouvelle annonce',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/create-announcement'),
            icon: const Icon(Iconsax.add),
            label: const Text('Créer une annonce'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    final bool isOpen = announcement.isOpen;
    final DateTime createdAt = announcement.createdAt;
    final String timeAgo = _getTimeAgo(createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/announcement-detail', arguments: announcement);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec avatar et statut
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(announcement.creator?.avatar ?? 'https://avatar.iran.liara.run/public/33'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.creator?.name ?? 'Utilisateur anonyme',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOpen ? Iconsax.clock : Iconsax.lock_1,
                          size: 12,
                          color: isOpen ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOpen ? 'Ouverte' : 'Fermée',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),

              // Titre
              Text(
                announcement.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),

              // Description
              Text(
                announcement.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),

              // Informations supplémentaires
              Row(
                children: [
                  // Catégorie avec icône
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          announcement.category.icon,
                          size: 10,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          announcement.category.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),

                  // Localisation
                  Icon(Iconsax.location, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      announcement.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),

              // Budget et propositions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.wallet_3, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${announcement.budget} FCFA',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Iconsax.people, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${announcement.proposalCount} propositions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}
