import 'profile_model.dart';
import 'contract_model.dart';

/// Modèle de données pour les évaluations Supabase
class ReviewModel {
  final String id;
  final String contractId;
  final String reviewerId;
  final String revieweeId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final ProfileModel? reviewer;
  final ProfileModel? reviewee;
  final ContractModel? contract;

  ReviewModel({
    required this.id,
    required this.contractId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.reviewer,
    this.reviewee,
    this.contract,
  });

  /// Nom complet de celui qui évalue
  String? get reviewerName => reviewer?.fullName;

  /// Nom complet de celui qui est évalué
  String? get revieweeName => reviewee?.fullName;

  /// Avatar de celui qui évalue
  String? get reviewerAvatar => reviewer?.avatarUrl;

  /// Avatar de celui qui est évalué
  String? get revieweeAvatar => reviewee?.avatarUrl;

  /// Titre du contrat associé
  String? get contractTitle => contract?.announcementTitle;

  /// Vérification si c'est une bonne évaluation (4-5 étoiles)
  bool get isPositive => rating >= 4;

  /// Vérification si c'est une évaluation moyenne (3 étoiles)
  bool get isNeutral => rating == 3;

  /// Vérification si c'est une mauvaise évaluation (1-2 étoiles)
  bool get isNegative => rating <= 2;

  /// Représentation textuelle de la note
  String get ratingText {
    switch (rating) {
      case 1:
        return 'Très insatisfait';
      case 2:
        return 'Insatisfait';
      case 3:
        return 'Correct';
      case 4:
        return 'Satisfait';
      case 5:
        return 'Très satisfait';
      default:
        return 'Non noté';
    }
  }

  /// Étoiles visuelles
  String get stars => '★' * rating + '☆' * (5 - rating);

  /// Factory constructor depuis une Map (Supabase)
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    ProfileModel? reviewer;
    if (map['reviewer'] != null) {
      reviewer = ProfileModel.fromMap(Map<String, dynamic>.from(map['reviewer']));
    }

    ProfileModel? reviewee;
    if (map['reviewee'] != null) {
      reviewee = ProfileModel.fromMap(Map<String, dynamic>.from(map['reviewee']));
    }

    ContractModel? contract;
    if (map['contract'] != null) {
      contract = ContractModel.fromMap(Map<String, dynamic>.from(map['contract']));
    }

    return ReviewModel(
      id: map['id'],
      contractId: map['contract_id'],
      reviewerId: map['reviewer_id'],
      revieweeId: map['reviewee_id'],
      rating: map['rating'] ?? 0,
      comment: map['comment'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      reviewer: reviewer,
      reviewee: reviewee,
      contract: contract,
    );
  }

  /// Conversion vers Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'contract_id': contractId,
      'reviewer_id': reviewerId,
      'reviewee_id': revieweeId,
      'rating': rating,
      'comment': comment,
    };
  }

  /// Copie avec modifications
  ReviewModel copyWith({
    int? rating,
    String? comment,
    ProfileModel? reviewer,
    ProfileModel? reviewee,
    ContractModel? contract,
  }) {
    return ReviewModel(
      id: id,
      contractId: contractId,
      reviewerId: reviewerId,
      revieweeId: revieweeId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      reviewer: reviewer ?? this.reviewer,
      reviewee: reviewee ?? this.reviewee,
      contract: contract ?? this.contract,
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating, reviewerId: $reviewerId, revieweeId: $revieweeId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
