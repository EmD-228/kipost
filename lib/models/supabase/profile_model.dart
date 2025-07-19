/// Modèle de données pour les profils utilisateur Supabase
class ProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final Map<String, dynamic>? location;
  final double? averageRating;
  final bool isVerified;
  final DateTime createdAt;
  final List<String>? skills;
  final List<String>? portfolioImages;
  final int? completedContracts;

  ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.location,
    this.averageRating,
    this.isVerified = false,
    required this.createdAt,
    this.skills,
    this.portfolioImages,
    this.completedContracts,
  });

  /// Nom complet de l'utilisateur
  String get fullName => '$firstName $lastName';

  /// Initiales de l'utilisateur
  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Ville de l'utilisateur (si location disponible)
  String? get city => location?['city'];

  /// Pays de l'utilisateur (si location disponible)
  String? get country => location?['country'];

  /// Latitude de l'utilisateur (si location disponible)
  double? get latitude => location?['latitude']?.toDouble();

  /// Longitude de l'utilisateur (si location disponible)
  double? get longitude => location?['longitude']?.toDouble();

  /// Factory constructor depuis une Map (Supabase)
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      avatarUrl: map['avatar_url'],
      location: map['location'],
      averageRating: map['average_rating']?.toDouble(),
      isVerified: map['is_verified'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      skills: map['skills'] != null ? List<String>.from(map['skills']) : null,
      portfolioImages: map['portfolio_images'] != null ? List<String>.from(map['portfolio_images']) : null,
      completedContracts: map['completed_contracts'],
    );
  }

  /// Conversion vers Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'location': location,
      'is_verified': isVerified,
      'skills': skills,
      'portfolio_images': portfolioImages,
      'completed_contracts': completedContracts,
    };
  }

  /// Copie avec modifications
  ProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    Map<String, dynamic>? location,
    double? averageRating,
    bool? isVerified,
    List<String>? skills,
    List<String>? portfolioImages,
    int? completedContracts,
  }) {
    return ProfileModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      averageRating: averageRating ?? this.averageRating,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      skills: skills ?? this.skills,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      completedContracts: completedContracts ?? this.completedContracts,
    );
  }

  @override
  String toString() {
    return 'ProfileModel(id: $id, fullName: $fullName, isVerified: $isVerified, averageRating: $averageRating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
