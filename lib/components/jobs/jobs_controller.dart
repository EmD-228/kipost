import 'package:flutter/material.dart';
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:kipost/models/category.dart';
import 'package:kipost/services/announcement_service.dart';

class JobsController extends ChangeNotifier {
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
  
  // Filtres
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

  // Getters
  int get currentPage => _currentPage;
  int get limit => _limit;
  bool get isLoading => _isLoading;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  List<AnnouncementModel> get announcements => _announcements;
  Map<String, dynamic>? get paginationInfo => _paginationInfo;
  List<Category> get categories => _categories;
  String get selectedCategoryId => _selectedCategoryId;
  String get search => _search;

  /// Charge les annonces avec pagination
  Future<void> loadAnnouncements({bool reset = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    if (reset) {
      _currentPage = 0;
      _announcements.clear();
    }
    notifyListeners();

    try {
      final result = await _announcementService.getAnnouncementsPaginated(
        page: _currentPage,
        limit: _limit,
        category: _selectedCategoryId == 'all' ? null : _selectedCategoryId,
        searchQuery: _search.isEmpty ? null : _search,
      );

      _announcements = result['announcements'] as List<AnnouncementModel>;
      _paginationInfo = result['pagination'] as Map<String, dynamic>;
      _hasNextPage = _paginationInfo!['hasNextPage'] as bool;
      _hasPreviousPage = _paginationInfo!['hasPreviousPage'] as bool;
      _isLoading = false;
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Propager l'erreur pour que l'UI puisse la gérer
    }
  }

  /// Page suivante
  Future<void> nextPage() async {
    if (_hasNextPage && !_isLoading) {
      _currentPage++;
      await loadAnnouncements();
    }
  }

  /// Page précédente
  Future<void> previousPage() async {
    if (_hasPreviousPage && !_isLoading) {
      _currentPage--;
      await loadAnnouncements();
    }
  }

  /// Recherche avec reset de pagination
  Future<void> onSearchChanged(String value) async {
    _search = value;
    await loadAnnouncements(reset: true);
  }

  /// Changement de catégorie avec reset de pagination
  Future<void> onCategoryChanged(String categoryName) async {
    final category = _categories.firstWhere(
      (cat) => cat.name == categoryName,
    );
    _selectedCategoryId = category.id;
    await loadAnnouncements(reset: true);
  }

  /// Initialise le contrôleur
  Future<void> initialize() async {
    await loadAnnouncements();
  }
}
