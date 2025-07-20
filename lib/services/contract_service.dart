import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase/supabase_models.dart';
import 'supabase_service.dart';

/// Service de gestion des contrats
class ContractService {
  final SupabaseService _supabaseService = SupabaseService();
  
  SupabaseClient get _client => _supabaseService.client;

  /// Créer un nouveau contrat après acceptation d'une proposition
  Future<ContractModel> createContract({
    required String announcementId,
    required String proposalId,
    required String clientId,
    required String providerId,
    required double finalPrice,
    DateTime? startTime,
    String? estimatedDuration,
    Map<String, dynamic>? finalLocation,
    String? notes,
  }) async {
    try {
      final response = await _client.from('contracts').insert({
        'announcement_id': announcementId,
        'proposal_id': proposalId,
        'client_id': clientId,
        'provider_id': providerId,
        'final_price': finalPrice,
        'start_time': startTime?.toIso8601String(),
        'estimated_duration': estimatedDuration,
        'final_location': finalLocation,
        'notes': notes,
        'status': 'pending_approval',
        'payment_status': 'pending',
      }).select('''
        *,
        client:profiles!client_id(*),
        provider:profiles!provider_id(*),
        announcement:announcements!announcement_id(*),
        proposal:proposals!proposal_id(*)
      ''').single();

      return ContractModel.fromMap(response);
    } catch (e) {
      throw Exception('Erreur lors de la création du contrat: $e');
    }
  }

  /// Récupère un contrat par son ID
  Future<ContractModel?> getContract(String contractId) async {
    try {
      final response = await _client
          .from('contracts')
          .select('''
            *, 
            client:profiles!client_id(*),
            provider:profiles!provider_id(*),
            announcement:announcements!announcement_id(*),
            proposal:proposals!proposal_id(*)
          ''')
          .eq('id', contractId)
          .single();

      return ContractModel.fromMap(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du contrat: $e');
    }
  }

  /// Récupère les contrats d'un utilisateur (client ou prestataire)
  Future<List<ContractModel>> getUserContracts() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final response = await _client
          .from('contracts')
          .select('''
            *, 
            client:profiles!client_id(*),
            provider:profiles!provider_id(*),
            announcement:announcements!announcement_id(*),
            proposal:proposals!proposal_id(*)
          ''')
          .or('client_id.eq.${currentUser.id},provider_id.eq.${currentUser.id}')
          .order('created_at', ascending: false);

      return response.map((data) => ContractModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des contrats: $e');
    }
  }

  /// Récupère les contrats en tant que client
  Future<List<ContractModel>> getClientContracts() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final response = await _client
          .from('contracts')
          .select('''
            *, 
            client:profiles!client_id(*),
            provider:profiles!provider_id(*),
            announcement:announcements!announcement_id(*),
            proposal:proposals!proposal_id(*)
          ''')
          .eq('client_id', currentUser.id)
          .order('created_at', ascending: false);

      return response.map((data) => ContractModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des contrats client: $e');
    }
  }

  /// Récupère les contrats en tant que prestataire
  Future<List<ContractModel>> getProviderContracts() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final response = await _client
          .from('contracts')
          .select('''
            *, 
            client:profiles!client_id(*),
            provider:profiles!provider_id(*),
            announcement:announcements!announcement_id(*),
            proposal:proposals!proposal_id(*)
          ''')
          .eq('provider_id', currentUser.id)
          .order('created_at', ascending: false);

      return response.map((data) => ContractModel.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des contrats prestataire: $e');
    }
  }

  /// Démarre un contrat (prestataire)
  Future<void> startContract(String contractId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _client
          .from('contracts')
          .update({
            'status': 'in_progress',
            'start_date': DateTime.now().toIso8601String(),
          })
          .eq('id', contractId)
          .eq('provider_id', currentUser.id);
    } catch (e) {
      throw Exception('Erreur lors du démarrage du contrat: $e');
    }
  }

  /// Marque un contrat comme terminé (prestataire)
  Future<void> completeContract(String contractId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _client
          .from('contracts')
          .update({
            'status': 'completed',
            'completion_date': DateTime.now().toIso8601String(),
          })
          .eq('id', contractId)
          .eq('provider_id', currentUser.id);
    } catch (e) {
      throw Exception('Erreur lors de la finalisation du contrat: $e');
    }
  }

  /// Valide un contrat terminé (client)
  Future<void> validateContract(String contractId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Utiliser une fonction Edge pour gérer la validation et le paiement
      await _client.rpc('validate_contract', params: {
        'contract_id': contractId,
        'client_id': currentUser.id,
      });
    } catch (e) {
      throw Exception('Erreur lors de la validation du contrat: $e');
    }
  }

  /// Annule un contrat
  Future<void> cancelContract(String contractId, String reason) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _client
          .from('contracts')
          .update({
            'status': 'cancelled',
            'cancellation_reason': reason,
          })
          .eq('id', contractId)
          .or('client_id.eq.${currentUser.id},provider_id.eq.${currentUser.id}');
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation du contrat: $e');
    }
  }

  /// Met à jour les termes d'un contrat (négociation)
  Future<void> updateContractTerms(
    String contractId, {
    double? price,
    String? deliveryDate,
    String? description,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final updateData = <String, dynamic>{};
      
      if (price != null) updateData['price'] = price;
      if (deliveryDate != null) updateData['delivery_date'] = deliveryDate;
      if (description != null) updateData['description'] = description;

      if (updateData.isNotEmpty) {
        updateData['status'] = 'negotiating';
        
        await _client
            .from('contracts')
            .update(updateData)
            .eq('id', contractId)
            .or('client_id.eq.${currentUser.id},provider_id.eq.${currentUser.id}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du contrat: $e');
    }
  }

  /// Accepte les termes négociés d'un contrat
  Future<void> acceptContractTerms(String contractId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _client
          .from('contracts')
          .update({'status': 'accepted'})
          .eq('id', contractId)
          .or('client_id.eq.${currentUser.id},provider_id.eq.${currentUser.id}');
    } catch (e) {
      throw Exception('Erreur lors de l\'acceptation des termes: $e');
    }
  }

  /// Signale un problème sur un contrat
  Future<void> reportContractIssue(String contractId, String issue) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _client
          .from('contracts')
          .update({
            'status': 'disputed',
            'dispute_reason': issue,
          })
          .eq('id', contractId)
          .or('client_id.eq.${currentUser.id},provider_id.eq.${currentUser.id}');
    } catch (e) {
      throw Exception('Erreur lors du signalement: $e');
    }
  }

  /// Initie le paiement d'un contrat (client)
  Future<Map<String, dynamic>> initiatePayment(String contractId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Appel à une fonction Edge pour créer l'intention de paiement Stripe
      final response = await _client.functions.invoke('create-payment-intent', body: {
        'contract_id': contractId,
        'client_id': currentUser.id,
      });

      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de l\'initiation du paiement: $e');
    }
  }

  /// Confirme le paiement d'un contrat
  Future<void> confirmPayment(String contractId, String paymentIntentId) async {
    try {
      await _client.functions.invoke('confirm-payment', body: {
        'contract_id': contractId,
        'payment_intent_id': paymentIntentId,
      });
    } catch (e) {
      throw Exception('Erreur lors de la confirmation du paiement: $e');
    }
  }

  /// Écoute les changements d'un contrat en temps réel
  Stream<ContractModel?> watchContract(String contractId) {
    return _client
        .from('contracts')
        .stream(primaryKey: ['id'])
        .eq('id', contractId)
        .map((data) => data.isNotEmpty ? ContractModel.fromMap(data.first) : null);
  }

  /// Écoute les changements des contrats de l'utilisateur
  Stream<List<ContractModel>> watchUserContracts() {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    return _client
        .from('contracts')
        .stream(primaryKey: ['id'])
        .map((data) {
          // Filtrer côté client pour les contrats de l'utilisateur
          final userContracts = data.where((item) {
            final clientId = item['client_id'] as String?;
            final providerId = item['provider_id'] as String?;
            return clientId == currentUser.id || providerId == currentUser.id;
          }).toList();
          
          // Trier par date de création (plus récent en premier)
          userContracts.sort((a, b) {
            final aDate = DateTime.parse(a['created_at'] as String);
            final bDate = DateTime.parse(b['created_at'] as String);
            return bDate.compareTo(aDate);
          });
          
          return userContracts.map((item) => ContractModel.fromMap(item)).toList();
        });
  }
}
