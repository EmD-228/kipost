import 'profile_model.dart';
import 'announcement_model.dart';
import 'proposal_model.dart';

/// Modèle de données pour les contrats Supabase
class ContractModel {
  final String id;
  final String announcementId;
  final String proposalId;
  final String clientId;
  final String providerId;
  final double finalPrice;
  final DateTime? startTime;
  final String? estimatedDuration;
  final Map<String, dynamic>? finalLocation;
  final String? notes;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final ProfileModel? client;
  final ProfileModel? provider;
  final AnnouncementModel? announcement;
  final ProposalModel? proposal;

  ContractModel({
    required this.id,
    required this.announcementId,
    required this.proposalId,
    required this.clientId,
    required this.providerId,
    required this.finalPrice,
    this.startTime,
    this.estimatedDuration,
    this.finalLocation,
    this.notes,
    this.status = 'pending_approval',
    this.paymentStatus = 'pending',
    required this.createdAt,
    this.client,
    this.provider,
    this.announcement,
    this.proposal,
  });

  /// Nom complet du client
  String? get clientName => client?.fullName;

  /// Nom complet du prestataire
  String? get providerName => provider?.fullName;

  /// Avatar du client
  String? get clientAvatar => client?.avatarUrl;

  /// Avatar du prestataire
  String? get providerAvatar => provider?.avatarUrl;

  /// Titre de l'annonce
  String? get announcementTitle => announcement?.title;

  /// Ville du contrat
  String? get city => finalLocation?['city'];

  /// Pays du contrat
  String? get country => finalLocation?['country'];

  /// Vérification si le contrat est en attente d'approbation
  bool get isPendingApproval => status == 'pending_approval';

  /// Vérification si le contrat est en cours
  bool get isInProgress => status == 'in_progress';

  /// Vérification si le contrat est terminé
  bool get isCompleted => status == 'completed';

  /// Vérification si le contrat est annulé
  bool get isCancelled => status == 'cancelled';

  /// Vérification si le contrat est en litige
  bool get isDisputed => status == 'disputed';

  /// Vérification si le paiement est en attente
  bool get isPaymentPending => paymentStatus == 'pending';

  /// Vérification si le paiement est financé
  bool get isPaymentFunded => paymentStatus == 'funded';

  /// Vérification si le paiement est libéré
  bool get isPaymentReleased => paymentStatus == 'released';

  /// Factory constructor depuis une Map (Supabase)
  factory ContractModel.fromMap(Map<String, dynamic> map) {
    ProfileModel? client;
    if (map['client'] != null) {
      client = ProfileModel.fromMap(Map<String, dynamic>.from(map['client']));
    }

    ProfileModel? provider;
    if (map['provider'] != null) {
      provider = ProfileModel.fromMap(Map<String, dynamic>.from(map['provider']));
    }

    AnnouncementModel? announcement;
    if (map['announcement'] != null) {
      announcement = AnnouncementModel.fromMap(Map<String, dynamic>.from(map['announcement']));
    }

    ProposalModel? proposal;
    if (map['proposal'] != null) {
      proposal = ProposalModel.fromMap(Map<String, dynamic>.from(map['proposal']));
    }

    return ContractModel(
      id: map['id'],
      announcementId: map['announcement_id'],
      proposalId: map['proposal_id'],
      clientId: map['client_id'],
      providerId: map['provider_id'],
      finalPrice: map['final_price']?.toDouble() ?? 0.0,
      startTime: map['start_time'] != null ? DateTime.parse(map['start_time']) : null,
      estimatedDuration: map['estimated_duration'],
      finalLocation: map['final_location'],
      notes: map['notes'],
      status: map['status'] ?? 'pending_approval',
      paymentStatus: map['payment_status'] ?? 'pending',
      createdAt: DateTime.parse(map['created_at']),
      client: client,
      provider: provider,
      announcement: announcement,
      proposal: proposal,
    );
  }

  /// Conversion vers Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'announcement_id': announcementId,
      'proposal_id': proposalId,
      'client_id': clientId,
      'provider_id': providerId,
      'final_price': finalPrice,
      'start_time': startTime?.toIso8601String(),
      'estimated_duration': estimatedDuration,
      'final_location': finalLocation,
      'notes': notes,
      'status': status,
      'payment_status': paymentStatus,
    };
  }

  /// Copie avec modifications
  ContractModel copyWith({
    double? finalPrice,
    DateTime? startTime,
    String? estimatedDuration,
    Map<String, dynamic>? finalLocation,
    String? notes,
    String? status,
    String? paymentStatus,
    ProfileModel? client,
    ProfileModel? provider,
    AnnouncementModel? announcement,
    ProposalModel? proposal,
  }) {
    return ContractModel(
      id: id,
      announcementId: announcementId,
      proposalId: proposalId,
      clientId: clientId,
      providerId: providerId,
      finalPrice: finalPrice ?? this.finalPrice,
      startTime: startTime ?? this.startTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      finalLocation: finalLocation ?? this.finalLocation,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      client: client ?? this.client,
      provider: provider ?? this.provider,
      announcement: announcement ?? this.announcement,
      proposal: proposal ?? this.proposal,
    );
  }

  @override
  String toString() {
    return 'ContractModel(id: $id, status: $status, paymentStatus: $paymentStatus, finalPrice: $finalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContractModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
