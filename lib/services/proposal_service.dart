import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase/supabase_models.dart';
import 'supabase_service.dart';

/// Service de gestion des propositions
class ProposalService {
  final SupabaseService _supabaseService = SupabaseService();
  
  SupabaseClient get _client => _supabaseService.client;

  /// Crée une nouvelle proposition
  Future<String> createProposal({
    required String announcementId,
    required double proposedPrice,
    required String message,
    String? estimatedDuration,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final proposalData = {
        'announcement_id': announcementId,
        'provider_id': currentUser.id,
        'amount': proposedPrice,
        'message': message,
      };

      final response = await _client
          .from('proposals')
          .insert(proposalData)
          .select()
          .single();

      return response['id'];
    } catch (e) {
      Logger().e('Erreur lors de la création de la proposition: $e');
      throw Exception('Erreur lors de la création de la proposition: $e');
    }
  }

  /// Récupère les propositions pour une annonce
  Future<List<ProposalModel>> getProposalsForAnnouncement(String announcementId) async {
    try {
      final response = await _client
          .from('proposals')
          .select('*, provider:profiles!provider_id(*), announcement:announcements!announcement_id(*)')
          .eq('announcement_id', announcementId)
          .order('created_at', ascending: false);

      return response.map((data) => ProposalModel.fromMap(data)).toList();
    } catch (e) {
      Logger().e('Erreur lors de la récupération des propositions: $e');
      throw Exception('Erreur lors de la récupération des propositions: $e');
    }
  }

  /// Récupère les propositions d'un prestataire
  Future<List<ProposalModel>> getProviderProposals() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final response = await _client
          .from('proposals')
          .select('*, provider:profiles!provider_id(*), announcement:announcements!announcement_id(*)')
          .eq('provider_id', currentUser.id)
          .order('created_at', ascending: false);

      return response.map((data) => ProposalModel.fromMap(data)).toList();
    } catch (e) {
      Logger().e('Erreur lors de la récupération des propositions: $e');
      throw Exception('Erreur lors de la récupération des propositions: $e');
    }
  }

  /// Récupère les propositions reçues par un client
  Future<List<ProposalModel>> getClientProposals() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // D'abord récupérer les IDs des annonces du client
      final announcementsResponse = await _client
          .from('announcements')
          .select('id')
          .eq('client_id', currentUser.id);

      if (announcementsResponse.isEmpty) {
        return [];
      }

      final announcementIds = announcementsResponse
          .map((announcement) => announcement['id'] as String)
          .toList();

      // Ensuite récupérer les propositions pour ces annonces
      final response = await _client
          .from('proposals')
          .select('*, provider:profiles!provider_id(*), announcement:announcements!announcement_id(*)')
          .inFilter('announcement_id', announcementIds)
          .order('created_at', ascending: false);

      return response.map((data) => ProposalModel.fromMap(data)).toList();
    } catch (e) {
      Logger().e('Erreur lors de la récupération des propositions reçues: $e');
      throw Exception('Erreur lors de la récupération des propositions reçues: $e');
    }
  }

  /// Récupère une proposition par son ID
  Future<ProposalModel?> getProposal(String proposalId) async {
    try {
      final response = await _client
          .from('proposals')
          .select('*, provider:profiles!provider_id(*), announcement:announcements!announcement_id(*)')
          .eq('id', proposalId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return ProposalModel.fromMap(response);
    } catch (e) {
      Logger().e('Erreur lors de la récupération de la proposition: $e');
      throw Exception('Erreur lors de la récupération de la proposition: $e');
    }
  }

  /// Met à jour une proposition
  Future<void> updateProposal(
    String proposalId, {
    double? proposedPrice,
    String? message,
    String? estimatedDuration,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final updateData = <String, dynamic>{};
      
      if (proposedPrice != null) updateData['proposed_price'] = proposedPrice;
      if (message != null) updateData['message'] = message;
      if (estimatedDuration != null) updateData['estimated_duration'] = estimatedDuration;

      if (updateData.isNotEmpty) {
        await _client
            .from('proposals')
            .update(updateData)
            .eq('id', proposalId)
            .eq('provider_id', currentUser.id);
      }
    } catch (e) {
      Logger().e('Erreur lors de la mise à jour de la proposition: $e');
      throw Exception('Erreur lors de la mise à jour de la proposition: $e');
    }
  }

  /// Accepte une proposition (client)
  Future<void> acceptProposal(String proposalId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Vérifier que l'utilisateur est le propriétaire de l'annonce
      final proposal = await getProposal(proposalId);
      if (proposal == null) {
        throw Exception('Proposition non trouvée');
      }

      // Vérifier que l'utilisateur est bien le propriétaire de l'annonce
      if (proposal.announcement?.clientId != currentUser.id) {
        throw Exception('Vous n\'êtes pas autorisé à accepter cette proposition');
      }

      // Accepter la proposition
      final acceptResult = await _client
          .from('proposals')
          .update({'status': 'accepted'})
          .eq('id', proposalId)
          .select();
      
      if (acceptResult.isEmpty) {
        throw Exception('Impossible de mettre à jour la proposition');
      }

      // Mettre à jour l'annonce avec le prestataire sélectionné et changer son statut
      await _client
          .from('announcements')
          .update({
            'status': 'assigned',
            'selected_provider_id': proposal.providerId,
          })
          .eq('id', proposal.announcementId);

      // Rejeter automatiquement toutes les autres propositions pour cette annonce
      await _client
          .from('proposals')
          .update({'status': 'rejected'})
          .eq('announcement_id', proposal.announcementId)
          .neq('id', proposalId);

    } catch (e) {
      Logger().e('Erreur lors de l\'acceptation de la proposition: $e');
      throw Exception('Erreur lors de l\'acceptation de la proposition: $e');
    }
  }

  /// Rejette une proposition (client)
  Future<void> rejectProposal(String proposalId, {String? reason}) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final updateData = {
        'status': 'rejected',
      };
      
      if (reason != null) {
        updateData['rejection_reason'] = reason;
      }

      await _client
          .from('proposals')
          .update(updateData)
          .eq('id', proposalId);
    } catch (e) {
      Logger().e('Erreur lors du rejet de la proposition: $e');
      throw Exception('Erreur lors du rejet de la proposition: $e');
    }
  }

  /// Retire une proposition (prestataire)
  Future<void> withdrawProposal(String proposalId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _client
          .from('proposals')
          .update({'status': 'withdrawn'})
          .eq('id', proposalId)
          .eq('provider_id', currentUser.id);
    } catch (e) {
      Logger().e('Erreur lors du retrait de la proposition: $e');
      throw Exception('Erreur lors du retrait de la proposition: $e');
    }
  }

  /// Supprime une proposition
  Future<void> deleteProposal(String proposalId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _client
          .from('proposals')
          .delete()
          .eq('id', proposalId)
          .eq('provider_id', currentUser.id);
    } catch (e) {
      Logger().e('Erreur lors de la suppression de la proposition: $e');
      throw Exception('Erreur lors de la suppression de la proposition: $e');
    }
  }

  /// Vérifie si l'utilisateur actuel a déjà postulé pour une annonce
  Future<bool> hasUserAlreadyApplied(String announcementId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      return false;
    }

    try {
      final response = await _client
          .from('proposals')
          .select('id')
          .eq('announcement_id', announcementId)
          .eq('provider_id', currentUser.id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      Logger().e('Erreur lors de la vérification de candidature: $e');
      throw Exception('Erreur lors de la vérification de candidature: $e');
    }
  }

  /// Envoie une proposition simple avec message
  Future<String> sendProposal({
    required String announcementId,
    required String message,
    double? proposedPrice,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final proposalData = <String, dynamic>{
        'announcement_id': announcementId,
        'provider_id': currentUser.id,
        'message': message,
        'status': 'pending',
      };

      if (proposedPrice != null) {
        proposalData['amount'] = proposedPrice;
      }

      final response = await _client
          .from('proposals')
          .insert(proposalData)
          .select()
          .single();

      return response['id'];
    } catch (e) {
      Logger().e('Erreur lors de l\'envoi de la proposition: $e');
      throw Exception('Erreur lors de l\'envoi de la proposition: $e');
    }
  }

  /// Écoute les changements de propositions en temps réel pour une annonce
  Stream<List<ProposalModel>> watchProposalsForAnnouncement(String announcementId) {
    return _client
        .from('proposals')
        .stream(primaryKey: ['id'])
        .eq('announcement_id', announcementId)
        .order('created_at', ascending: false)
        .map((data) => 
            data.map((item) => ProposalModel.fromMap(item)).toList());
  }

  /// Écoute les changements de propositions du prestataire connecté
  Stream<List<ProposalModel>> watchProviderProposals() {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    return _client
        .from('proposals')
        .stream(primaryKey: ['id'])
        .eq('provider_id', currentUser.id)
        .order('created_at', ascending: false)
        .map((data) => 
            data.map((item) => ProposalModel.fromMap(item)).toList());
  }
}
