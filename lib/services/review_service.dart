import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase/supabase_models.dart';
import 'supabase_service.dart';

/// Service de gestion des évaluations et avis
class ReviewService {
  final SupabaseService _supabaseService = SupabaseService();
  
  SupabaseClient get _client => _supabaseService.client;

  /// Crée une nouvelle évaluation
  Future<String> createReview({
    required String contractId,
    required String revieweeId,
    required double rating,
    required String comment,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final reviewData = {
        'contract_id': contractId,
        'reviewer_id': currentUser.id,
        'reviewee_id': revieweeId,
        'rating': rating,
        'comment': comment,
      };

      final response = await _client
          .from('reviews')
          .insert(reviewData)
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'évaluation: $e');
    }
  }

  /// Récupère les évaluations d'un utilisateur (reçues)
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *, 
            reviewer:profiles!reviewer_id(*),
            reviewee:profiles!reviewee_id(*),
            contract:contracts!contract_id(*)
          ''')
          .eq('reviewee_id', userId)
          .order('created_at', ascending: false);

      return response.map((data) => ReviewModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des évaluations: $e');
    }
  }

  /// Récupère les évaluations données par un utilisateur
  Future<List<ReviewModel>> getUserGivenReviews() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final response = await _client
          .from('reviews')
          .select('''
            *, 
            reviewer:profiles!reviewer_id(*),
            reviewee:profiles!reviewee_id(*),
            contract:contracts!contract_id(*)
          ''')
          .eq('reviewer_id', currentUser.id)
          .order('created_at', ascending: false);

      return response.map((data) => ReviewModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des évaluations données: $e');
    }
  }

  /// Récupère une évaluation par son ID
  Future<ReviewModel?> getReview(String reviewId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *, 
            reviewer:profiles!reviewer_id(*),
            reviewee:profiles!reviewee_id(*),
            contract:contracts!contract_id(*)
          ''')
          .eq('id', reviewId)
          .single();

      return ReviewModel.fromMap(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'évaluation: $e');
    }
  }

  /// Récupère les évaluations d'un contrat
  Future<List<ReviewModel>> getContractReviews(String contractId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *, 
            reviewer:profiles!reviewer_id(*),
            reviewee:profiles!reviewee_id(*),
            contract:contracts!contract_id(*)
          ''')
          .eq('contract_id', contractId)
          .order('created_at', ascending: false);

      return response.map((data) => ReviewModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des évaluations du contrat: $e');
    }
  }

  /// Met à jour une évaluation
  Future<void> updateReview(
    String reviewId, {
    double? rating,
    String? comment,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final updateData = <String, dynamic>{};
      
      if (rating != null) updateData['rating'] = rating;
      if (comment != null) updateData['comment'] = comment;

      if (updateData.isNotEmpty) {
        await _client
            .from('reviews')
            .update(updateData)
            .eq('id', reviewId)
            .eq('reviewer_id', currentUser.id);
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'évaluation: $e');
    }
  }

  /// Supprime une évaluation
  Future<void> deleteReview(String reviewId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _client
          .from('reviews')
          .delete()
          .eq('id', reviewId)
          .eq('reviewer_id', currentUser.id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'évaluation: $e');
    }
  }

  /// Calcule la note moyenne d'un utilisateur
  Future<Map<String, dynamic>> getUserRatingStats(String userId) async {
    try {
      final response = await _client.rpc('get_user_rating_stats', params: {
        'user_id': userId,
      });

      return {
        'average_rating': response['average_rating'] ?? 0.0,
        'total_reviews': response['total_reviews'] ?? 0,
        'rating_distribution': response['rating_distribution'] ?? {},
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }

  /// Vérifie si l'utilisateur peut évaluer un contrat
  Future<bool> canReviewContract(String contractId, String revieweeId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return false;

    try {
      // Vérifier si l'évaluation existe déjà
      final existingReview = await _client
          .from('reviews')
          .select()
          .eq('contract_id', contractId)
          .eq('reviewer_id', currentUser.id)
          .eq('reviewee_id', revieweeId)
          .maybeSingle();

      if (existingReview != null) return false;

      // Vérifier si le contrat est terminé et validé
      final contract = await _client
          .from('contracts')
          .select()
          .eq('id', contractId)
          .eq('status', 'validated')
          .or('client_id.eq.${currentUser.id},provider_id.eq.${currentUser.id}')
          .maybeSingle();

      return contract != null;
    } catch (e) {
      return false;
    }
  }

  /// Récupère les évaluations récentes du système
  Future<List<ReviewModel>> getRecentReviews({int limit = 10}) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *, 
            reviewer:profiles!reviewer_id(*),
            reviewee:profiles!reviewee_id(*),
            contract:contracts!contract_id(*)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((data) => ReviewModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des évaluations récentes: $e');
    }
  }

  /// Récupère les meilleures évaluations d'un utilisateur
  Future<List<ReviewModel>> getTopUserReviews(String userId, {int limit = 5}) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *, 
            reviewer:profiles!reviewer_id(*),
            reviewee:profiles!reviewee_id(*),
            contract:contracts!contract_id(*)
          ''')
          .eq('reviewee_id', userId)
          .gte('rating', 4.0)
          .order('rating', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((data) => ReviewModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des meilleures évaluations: $e');
    }
  }

  /// Signale une évaluation inappropriée
  Future<void> reportReview(String reviewId, String reason) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Insérer un signalement dans une table dédiée
      await _client.from('review_reports').insert({
        'review_id': reviewId,
        'reporter_id': currentUser.id,
        'reason': reason,
      });
    } catch (e) {
      throw Exception('Erreur lors du signalement de l\'évaluation: $e');
    }
  }

  /// Écoute les changements d'évaluations d'un utilisateur en temps réel
  Stream<List<ReviewModel>> watchUserReviews(String userId) {
    return _client
        .from('reviews')
        .stream(primaryKey: ['id'])
        .eq('reviewee_id', userId)
        .order('created_at', ascending: false)
        .map((data) => 
            data.map((item) => ReviewModel.fromMap(item)).toList());
  }
}
