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
      final response = await _client
          .from('proposals')
          .select('''
            *, 
            provider:profiles!provider_id(*), 
            announcement:announcements!announcement_id(*)
          ''')
          .eq('announcement.client_id', currentUser.id)
          .order('created_at', ascending: false);

      return response.map((data) => ProposalModel.fromMap(data)).toList();
    } catch (e) {
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
          .single();

      return ProposalModel.fromMap(response);
    } catch (e) {
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

      // Démarrer une transaction pour accepter la proposition et rejeter les autres
      await _client.rpc('accept_proposal', params: {
        'proposal_id': proposalId,
        'client_id': currentUser.id,
      });
    } catch (e) {
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
      throw Exception('Erreur lors de la suppression de la proposition: $e');
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
