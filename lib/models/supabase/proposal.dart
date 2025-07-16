/// Modèle de données pour les propositions (Supabase)
class ProposalModel {
  final String id;
  final String announcementId;
  final String providerId;
  final double proposedPrice;
  final String message;
  final String? estimatedDuration;
  final String status; // 'pending', 'accepted', 'rejected', 'withdrawn'
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Map<String, dynamic>? provider;
  final Map<String, dynamic>? announcement;

  ProposalModel({
    required this.id,
    required this.announcementId,
    required this.providerId,
    required this.proposedPrice,
    required this.message,
    this.estimatedDuration,
    this.status = 'pending',
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.provider,
    this.announcement,
  });

  /// Vérifie si la proposition est en attente
  bool get isPending => status == 'pending';

  /// Vérifie si la proposition est acceptée
  bool get isAccepted => status == 'accepted';

  /// Vérifie si la proposition est rejetée
  bool get isRejected => status == 'rejected';

  /// Vérifie si la proposition est retirée
  bool get isWithdrawn => status == 'withdrawn';

  /// Factory constructor depuis une Map (Supabase)
  factory ProposalModel.fromMap(Map<String, dynamic> map) {
    return ProposalModel(
      id: map['id'],
      announcementId: map['announcement_id'],
      providerId: map['provider_id'],
      proposedPrice: map['proposed_price']?.toDouble() ?? 0.0,
      message: map['message'] ?? '',
      estimatedDuration: map['estimated_duration'],
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejection_reason'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      provider: map['provider'],
      announcement: map['announcement'],
    );
  }

  /// Conversion vers Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'announcement_id': announcementId,
      'provider_id': providerId,
      'proposed_price': proposedPrice,
      'message': message,
      'estimated_duration': estimatedDuration,
      'status': status,
      'rejection_reason': rejectionReason,
    };
  }

  /// Copie avec modifications
  ProposalModel copyWith({
    double? proposedPrice,
    String? message,
    String? estimatedDuration,
    String? status,
    String? rejectionReason,
  }) {
    return ProposalModel(
      id: id,
      announcementId: announcementId,
      providerId: providerId,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      message: message ?? this.message,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      provider: provider,
      announcement: announcement,
    );
  }

  @override
  String toString() {
    return 'ProposalModel(id: $id, announcementId: $announcementId, proposedPrice: $proposedPrice, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProposalModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
