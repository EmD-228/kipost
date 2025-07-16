import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/components/text/app_text.dart';
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:kipost/models/category.dart';
import 'package:kipost/components/home/search_bar.dart' as custom;
import 'package:kipost/components/home/filter_chips.dart';
import 'package:kipost/services/announcement_service.dart';
import 'package:kipost/theme/app_colors.dart';

class JobsTab extends StatefulWidget {
  const JobsTab({super.key});

  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  // Service d'annonces avec pagination
  final AnnouncementService _announcementService = AnnouncementService();
  
  // Variables de pagination
  int _currentPage = 0;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasNextPage = true;
  bool _hasPreviousPage = false;
  List<AnnouncementModel> _announcements = [];
  Map<String, dynamic>? _paginationInfo;
  
  final List<Category> _categories = [
    Category(
      id: 'all',
      name: 'Toutes',
      icon: Icons.all_inclusive,
      description: 'Toutes catégories',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    ...Category.getDefaultCategories(),
  ];
  String _selectedCategoryId = 'all';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  /// Charge les annonces avec pagination
  Future<void> _loadAnnouncements({bool reset = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _currentPage = 0;
        _announcements.clear();
      }
    });

    try {
      final result = await _announcementService.getAnnouncementsPaginated(
        page: _currentPage,
        limit: _limit,
        category: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
        searchQuery: _search.isEmpty ? null : _search,
      );

      setState(() {
        _announcements = result['announcements'] as List<AnnouncementModel>;
        _paginationInfo = result['pagination'] as Map<String, dynamic>;
        _hasNextPage = _paginationInfo!['hasNextPage'] as bool;
        _hasPreviousPage = _paginationInfo!['hasPreviousPage'] as bool;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Afficher l'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Page suivante
  void _nextPage() {
    if (_hasNextPage && !_isLoading) {
      setState(() {
        _currentPage++;
      });
      _loadAnnouncements();
    }
  }

  /// Page précédente
  void _previousPage() {
    if (_hasPreviousPage && !_isLoading) {
      setState(() {
        _currentPage--;
      });
      _loadAnnouncements();
    }
  }

  /// Recherche avec reset de pagination
  void _onSearchChanged(String value) {
    setState(() {
      _search = value;
    });
    _loadAnnouncements(reset: true);
  }

  /// Changement de catégorie avec reset de pagination
  void _onCategoryChanged(String categoryName) {
    final category = _categories.firstWhere(
      (cat) => cat.name == categoryName,
    );
    setState(() {
      _selectedCategoryId = category.id;
    });
    _loadAnnouncements(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.grey.shade50,

            expandedHeight: 145.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 5,
                ),
                child: Column(
                  children: [
                    custom.SearchBar(
                      search: _search,
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 8),
                    HorizontalFilters(
                      categories: _categories.map((cat) => cat.name).toList(),
                      selectedCategory:
                          _categories
                              .firstWhere(
                                (cat) => cat.id == _selectedCategoryId,
                              )
                              .name,
                      onCategoryChanged: _onCategoryChanged,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Liste des annonces avec pagination
          if (_isLoading && _announcements.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_announcements.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.search_normal,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune annonce trouvée',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Essayez de modifier vos critères de recherche',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _announcements.length - 1 ? 0 : 8,
                    ),
                    child: _buildAnnouncementCard(_announcements[index]),
                  );
                },
                childCount: _announcements.length,
              ),
            ),

          // Pagination et loading
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Indicateur de chargement pour la pagination
                  if (_isLoading && _announcements.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),

                  // Informations de pagination
                  if (_paginationInfo != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Page ${_paginationInfo!['currentPage'] + 1} sur ${_paginationInfo!['totalPages']}',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_announcements.length} sur ${_paginationInfo!['totalCount']} annonces',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Boutons de navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton page précédente
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _hasPreviousPage && !_isLoading ? _previousPage : null,
                          icon: const Icon(Iconsax.arrow_left_2),
                          label: const Text('Précédent'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            foregroundColor: AppColors.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Bouton page suivante
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _hasNextPage && !_isLoading ? _nextPage : null,
                          icon: const Icon(Iconsax.arrow_right_3),
                          label: const Text('Suivant'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100), // Espace pour le bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    final bool isOpen = announcement.status == 'active';
    final DateTime createdAt = announcement.createdAt;
    final String timeAgo = _getTimeAgo(createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
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
                    backgroundImage: NetworkImage(
                      announcement.client?.avatarUrl ??
                          'https://avatar.iran.liara.run/public/33',
                    ),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${announcement.client?.firstName ?? ''} ${announcement.client?.lastName ?? ''}'.trim().isNotEmpty
                              ? '${announcement.client?.firstName ?? ''} ${announcement.client?.lastName ?? ''}'.trim()
                              : 'Utilisateur anonyme',
                          style: const TextStyle(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isOpen
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
                announcement.title.capitalizeFirst ?? announcement.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 5),

              // Description
              AppText.bodySmall(announcement.description.capitalizeFirst ?? announcement.description),

              const SizedBox(height: 12),

              // Informations supplémentaires
              Row(
                children: [
                  // Catégorie avec icône
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category,
                          size: 12,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          announcement.category,
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
                      announcement.location['city']?.toString() ?? 'Non spécifié',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Budget et urgence
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (announcement.budget != null)
                    Row(
                      children: [
                        Icon(
                          Iconsax.wallet_3,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${announcement.budget!.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(),
                  
                  // Urgence
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getUrgencyColor(announcement.urgency).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      announcement.urgency,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getUrgencyColor(announcement.urgency),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'modéré':
        return Colors.orange;
      case 'faible':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
