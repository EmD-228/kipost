/// Modèle de données pour les évaluations (Supabase)
class ReviewModel {
  final String id;
  final String contractId;
  final String reviewerId;
  final String revieweeId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Map<String, dynamic>? reviewer;
  final Map<String, dynamic>? reviewee;
  final Map<String, dynamic>? contract;

  ReviewModel({
    required this.id,
    required this.contractId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.reviewer,
    this.reviewee,
    this.contract,
  });

  /// Vérifie si c'est une excellente évaluation (5 étoiles)
  bool get isExcellent => rating == 5.0;

  /// Vérifie si c'est une très bonne évaluation (4-5 étoiles)
  bool get isGood => rating >= 4.0;

  /// Vérifie si c'est une évaluation moyenne (3-4 étoiles)
  bool get isAverage => rating >= 3.0 && rating < 4.0;

  /// Vérifie si c'est une mauvaise évaluation (< 3 étoiles)
  bool get isPoor => rating < 3.0;

  /// Obtient la représentation en étoiles
  String get starsDisplay {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    
    String stars = '★' * fullStars;
    if (hasHalfStar) stars += '☆';
    
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    stars += '☆' * emptyStars;
    
    return stars;
  }

  /// Factory constructor depuis une Map (Supabase)
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'],
      contractId: map['contract_id'],
      reviewerId: map['reviewer_id'],
      revieweeId: map['reviewee_id'],
      rating: map['rating']?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      reviewer: map['reviewer'],
      reviewee: map['reviewee'],
      contract: map['contract'],
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
    double? rating,
    String? comment,
  }) {
    return ReviewModel(
      id: id,
      contractId: contractId,
      reviewerId: reviewerId,
      revieweeId: revieweeId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      reviewer: reviewer,
      reviewee: reviewee,
      contract: contract,
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
