
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Service de gestion des annonces
class AnnouncementService {
  final SupabaseService _supabaseService = SupabaseService();
  
  SupabaseClient get _client => _supabaseService.client;

  /// Crée une nouvelle annonce
  Future<String> createAnnouncement({
    required String title,
    required String description,
    required String category,
    required Map<String, dynamic> location,
    double? budget,
    String urgency = 'Modéré',
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final announcementData = {
        'client_id': currentUser.id,
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'budget': budget,
        'urgency': urgency,
        'status': 'active',
      };

      final response = await _client
          .from('announcements')
          .insert(announcementData)
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'annonce: $e');
    }
  }

  /// Récupère toutes les annonces avec filtres optionnels
  Future<List<AnnouncementModel>> getAnnouncements({
    String? category,
    Map<String, dynamic>? location,
    double? maxBudget,
    String? searchQuery,
  }) async {
    try {
      // Construction progressive de la requête
      String queryString = '*, client:profiles!client_id(*)';
      
      var queryBuilder = _client
          .from('announcements')
          .select(queryString);
      
      // Application des filtres
      queryBuilder = queryBuilder.eq('status', 'active');
      
      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category);
      }

      if (maxBudget != null) {
        queryBuilder = queryBuilder.lte('budget', maxBudget);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryBuilder = queryBuilder.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      // Ordre et exécution
      final response = await queryBuilder.order('created_at', ascending: false);

      return response.map((data) => AnnouncementModel.fromMap(data)).toList();
    } catch (e) {
      Logger().e('Erreur lors de la récupération des annonces: $e');
      throw Exception('Erreur lors de la récupération des annonces: $e');
    }
  }

  /// Récupère les annonces avec pagination (10 par page)
  Future<Map<String, dynamic>> getAnnouncementsPaginated({
    int page = 0,
    int limit = 10,
    String? category,
    Map<String, dynamic>? location,
    double? maxBudget,
    String? searchQuery,
  }) async {
    try {
      // Calcul de l'offset
      final offset = page * limit;
      
      // Construction progressive de la requête pour le count
      var countQuery = _client
          .from('announcements')
          .select('id');
      
      // Application des filtres pour le count
      countQuery = countQuery.eq('status', 'active');
      
      if (category != null) {
        countQuery = countQuery.eq('category', category);
      }

      if (maxBudget != null) {
        countQuery = countQuery.lte('budget', maxBudget);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        countQuery = countQuery.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      // Construction de la requête principale
      String queryString = '*, client:profiles!client_id(*)';
      
      var queryBuilder = _client
          .from('announcements')
          .select(queryString);
      
      // Application des mêmes filtres
      queryBuilder = queryBuilder.eq('status', 'active');
      
      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category);
      }

      if (maxBudget != null) {
        queryBuilder = queryBuilder.lte('budget', maxBudget);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryBuilder = queryBuilder.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      // Exécution des requêtes
      final countResponse = await countQuery;
      final totalCount = countResponse.length;

      // Ordre, pagination et exécution de la requête principale
      final response = await queryBuilder
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final announcements = response.map((data) => AnnouncementModel.fromMap(data)).toList();

      // Calculs de pagination
      final totalPages = (totalCount / limit).ceil();
      final hasNextPage = page < totalPages - 1;
      final hasPreviousPage = page > 0;

      return {
        'announcements': announcements,
        'pagination': {
          'currentPage': page,
          'totalPages': totalPages,
          'totalCount': totalCount,
          'hasNextPage': hasNextPage,
          'hasPreviousPage': hasPreviousPage,
          'limit': limit,
          'offset': offset,
        }
      };
    } catch (e) {
      Logger().e('Erreur lors de la récupération des annonces paginées: $e');
      throw Exception('Erreur lors de la récupération des annonces paginées: $e');
    }
  }

  /// Récupère une annonce par son ID
  Future<AnnouncementModel?> getAnnouncement(String announcementId) async {
    try {
      final response = await _client
          .from('announcements')
          .select('*, client:profiles!client_id(*)')
          .eq('id', announcementId)
          .single();

      return AnnouncementModel.fromMap(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'annonce: $e');
    }
  }

  /// Récupère les annonces d'un utilisateur
  Future<List<AnnouncementModel>> getUserAnnouncements() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final response = await _client
          .from('announcements')
          .select('*, client:profiles!client_id(*)')
          .eq('client_id', currentUser.id)
          .order('created_at', ascending: false);

      return response.map((data) => AnnouncementModel.fromMap(data)).toList();
    } catch (e) {
      Logger().e('Erreur lors de la récupération des annonces: $e');
      throw Exception('Erreur lors de la récupération des annonces: $e');
    }
  }

  /// Met à jour une annonce
  Future<void> updateAnnouncement(
    String announcementId, {
    String? title,
    String? description,
    String? category,
    Map<String, dynamic>? location,
    double? budget,
    String? urgency,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final updateData = <String, dynamic>{};
      
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (location != null) updateData['location'] = location;
      if (budget != null) updateData['budget'] = budget;
      if (urgency != null) updateData['urgency'] = urgency;

      if (updateData.isNotEmpty) {
        await _client
            .from('announcements')
            .update(updateData)
            .eq('id', announcementId)
            .eq('client_id', currentUser.id);
      }
    } catch (e) {
      Logger().e('Erreur lors de la mise à jour de l\'annonce: $e');
      throw Exception('Erreur lors de la mise à jour de l\'annonce: $e');
    }
  }

  /// Supprime une annonce
  Future<void> deleteAnnouncement(String announcementId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _client
          .from('announcements')
          .delete()
          .eq('id', announcementId)
          .eq('client_id', currentUser.id);
    } catch (e) {
      Logger().e('Erreur lors de la suppression de l\'annonce: $e');
      throw Exception('Erreur lors de la suppression de l\'annonce: $e');
    }
  }

  /// Ferme une annonce (change le statut)
  Future<void> closeAnnouncement(String announcementId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _client
          .from('announcements')
          .update({'status': 'cancelled'})
          .eq('id', announcementId)
          .eq('client_id', currentUser.id);
    } catch (e) {
      Logger().e('Erreur lors de la fermeture de l\'annonce: $e');
      throw Exception('Erreur lors de la fermeture de l\'annonce: $e');
    }
  }

  /// Recherche d'annonces par géolocalisation
  Future<List<AnnouncementModel>> searchAnnouncementsByLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      // Utilisation d'une fonction Edge ou d'une requête RPC pour la géolocalisation
      final response = await _client.rpc('search_announcements_by_location', params: {
        'lat': latitude,
        'lng': longitude,
        'radius_km': radiusKm,
      });

      return response.map((data) => AnnouncementModel.fromMap(data)).toList();
    } catch (e) {
      Logger().e('Erreur lors de la recherche géographique: $e');
      throw Exception('Erreur lors de la recherche géographique: $e');
    }
  }

  /// Écoute les changements d'annonces en temps réel
  Stream<List<AnnouncementModel>> watchAnnouncements({
    String? category,
    Map<String, dynamic>? location,
  }) {
    // Stream simple sans filtres complexes pour éviter les erreurs de type
    return _client
        .from('announcements')
        .stream(primaryKey: ['id'])
        .map((data) {
          var filteredData = data.where((item) {
            bool matchesStatus = item['status'] == 'active';
            bool matchesCategory = category == null || item['category'] == category;
            return matchesStatus && matchesCategory;
          }).toList();
          
          return filteredData.map((item) => AnnouncementModel.fromMap(item)).toList();
        });
  }
}
