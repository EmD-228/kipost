import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement.dart';
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
    bool isUrgent = false,
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
        'is_urgent': isUrgent,
        'status': 'open',
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
      var query = _client
          .from('announcements')
          .select('*, client:profiles!client_id(*)')
          .eq('status', 'open')
          .order('created_at', ascending: false);

      if (category != null) {
        query = query.eq('category', category);
      }

      if (maxBudget != null) {
        query = query.lte('budget', maxBudget);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      final response = await query;

      return response.map((data) => AnnouncementModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des annonces: $e');
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
    bool? isUrgent,
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
      if (isUrgent != null) updateData['is_urgent'] = isUrgent;

      if (updateData.isNotEmpty) {
        await _client
            .from('announcements')
            .update(updateData)
            .eq('id', announcementId)
            .eq('client_id', currentUser.id);
      }
    } catch (e) {
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
          .update({'status': 'closed'})
          .eq('id', announcementId)
          .eq('client_id', currentUser.id);
    } catch (e) {
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
      throw Exception('Erreur lors de la recherche géographique: $e');
    }
  }

  /// Écoute les changements d'annonces en temps réel
  Stream<List<AnnouncementModel>> watchAnnouncements({
    String? category,
    Map<String, dynamic>? location,
  }) {
    var query = _client
        .from('announcements')
        .stream(primaryKey: ['id'])
        .eq('status', 'open')
        .order('created_at', ascending: false);

    if (category != null) {
      query = query.eq('category', category);
    }

    return query.map((data) => 
        data.map((item) => AnnouncementModel.fromMap(item)).toList());
  }
}
