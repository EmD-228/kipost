/// Modèle de données pour les contrats (Supabase)
class ContractModel {
  final String id;
  final String announcementId;
  final String proposalId;
  final String clientId;
  final String providerId;
  final double price;
  final String? description;
  final String? deliveryDate;
  final String status; // 'created', 'negotiating', 'accepted', 'in_progress', 'completed', 'validated', 'cancelled', 'disputed'
  final DateTime? startDate;
  final DateTime? completionDate;
  final String? cancellationReason;
  final String? disputeReason;
  final String? paymentIntentId;
  final String? paymentStatus; // 'pending', 'paid', 'failed', 'refunded'
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? provider;
  final Map<String, dynamic>? announcement;
  final Map<String, dynamic>? proposal;

  ContractModel({
    required this.id,
    required this.announcementId,
    required this.proposalId,
    required this.clientId,
    required this.providerId,
    required this.price,
    this.description,
    this.deliveryDate,
    this.status = 'created',
    this.startDate,
    this.completionDate,
    this.cancellationReason,
    this.disputeReason,
    this.paymentIntentId,
    this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.client,
    this.provider,
    this.announcement,
    this.proposal,
  });

  /// Vérifie si le contrat est en cours de négociation
  bool get isNegotiating => status == 'negotiating';

  /// Vérifie si le contrat est accepté
  bool get isAccepted => status == 'accepted';

  /// Vérifie si le contrat est en cours
  bool get isInProgress => status == 'in_progress';

  /// Vérifie si le contrat est terminé
  bool get isCompleted => status == 'completed';

  /// Vérifie si le contrat est validé
  bool get isValidated => status == 'validated';

  /// Vérifie si le contrat est annulé
  bool get isCancelled => status == 'cancelled';

  /// Vérifie si le contrat est en litige
  bool get isDisputed => status == 'disputed';

  /// Vérifie si le paiement est en attente
  bool get isPaymentPending => paymentStatus == 'pending';

  /// Vérifie si le paiement est effectué
  bool get isPaymentPaid => paymentStatus == 'paid';

  /// Factory constructor depuis une Map (Supabase)
  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      id: map['id'],
      announcementId: map['announcement_id'],
      proposalId: map['proposal_id'],
      clientId: map['client_id'],
      providerId: map['provider_id'],
      price: map['price']?.toDouble() ?? 0.0,
      description: map['description'],
      deliveryDate: map['delivery_date'],
      status: map['status'] ?? 'created',
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      completionDate: map['completion_date'] != null ? DateTime.parse(map['completion_date']) : null,
      cancellationReason: map['cancellation_reason'],
      disputeReason: map['dispute_reason'],
      paymentIntentId: map['payment_intent_id'],
      paymentStatus: map['payment_status'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      client: map['client'],
      provider: map['provider'],
      announcement: map['announcement'],
      proposal: map['proposal'],
    );
  }

  /// Conversion vers Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'announcement_id': announcementId,
      'proposal_id': proposalId,
      'client_id': clientId,
      'provider_id': providerId,
      'price': price,
      'description': description,
      'delivery_date': deliveryDate,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'completion_date': completionDate?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'dispute_reason': disputeReason,
      'payment_intent_id': paymentIntentId,
      'payment_status': paymentStatus,
    };
  }

  /// Copie avec modifications
  ContractModel copyWith({
    double? price,
    String? description,
    String? deliveryDate,
    String? status,
    DateTime? startDate,
    DateTime? completionDate,
    String? cancellationReason,
    String? disputeReason,
    String? paymentIntentId,
    String? paymentStatus,
  }) {
    return ContractModel(
      id: id,
      announcementId: announcementId,
      proposalId: proposalId,
      clientId: clientId,
      providerId: providerId,
      price: price ?? this.price,
      description: description ?? this.description,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      disputeReason: disputeReason ?? this.disputeReason,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      client: client,
      provider: provider,
      announcement: announcement,
      proposal: proposal,
    );
  }

  @override
  String toString() {
    return 'ContractModel(id: $id, price: $price, status: $status, paymentStatus: $paymentStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContractModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
