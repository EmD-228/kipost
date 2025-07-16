import 'profile_model.dart';
import 'announcement_model.dart';

/// Modèle de données pour les propositions Supabase
class ProposalModel {
  final String id;
  final String announcementId;
  final String providerId;
  final String message;
  final double? amount;
  final String status;
  final DateTime createdAt;
  final ProfileModel? provider;
  final AnnouncementModel? announcement;

  ProposalModel({
    required this.id,
    required this.announcementId,
    required this.providerId,
    required this.message,
    this.amount,
    this.status = 'pending',
    required this.createdAt,
    this.provider,
    this.announcement,
  });

  /// Nom complet du prestataire
  String? get providerName => provider?.fullName;

  /// Avatar du prestataire
  String? get providerAvatar => provider?.avatarUrl;

  /// Note moyenne du prestataire
  double? get providerRating => provider?.averageRating;

  /// Titre de l'annonce
  String? get announcementTitle => announcement?.title;

  /// Vérification si la proposition est en attente
  bool get isPending => status == 'pending';

  /// Vérification si la proposition est acceptée
  bool get isAccepted => status == 'accepted';

  /// Vérification si la proposition est rejetée
  bool get isRejected => status == 'rejected';

  /// Factory constructor depuis une Map (Supabase)
  factory ProposalModel.fromMap(Map<String, dynamic> map) {
    ProfileModel? provider;
    if (map['provider'] != null) {
      provider = ProfileModel.fromMap(Map<String, dynamic>.from(map['provider']));
    }

    AnnouncementModel? announcement;
    if (map['announcement'] != null) {
      announcement = AnnouncementModel.fromMap(Map<String, dynamic>.from(map['announcement']));
    }

    return ProposalModel(
      id: map['id'],
      announcementId: map['announcement_id'],
      providerId: map['provider_id'],
      message: map['message'] ?? '',
      amount: map['amount']?.toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['created_at']),
      provider: provider,
      announcement: announcement,
    );
  }

  /// Conversion vers Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'announcement_id': announcementId,
      'provider_id': providerId,
      'message': message,
      'amount': amount,
      'status': status,
    };
  }

  /// Copie avec modifications
  ProposalModel copyWith({
    String? message,
    double? amount,
    String? status,
    ProfileModel? provider,
    AnnouncementModel? announcement,
  }) {
    return ProposalModel(
      id: id,
      announcementId: announcementId,
      providerId: providerId,
      message: message ?? this.message,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt,
      provider: provider ?? this.provider,
      announcement: announcement ?? this.announcement,
    );
  }

  @override
  String toString() {
    return 'ProposalModel(id: $id, providerId: $providerId, status: $status, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProposalModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
