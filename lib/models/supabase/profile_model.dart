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

  ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.location,
    this.averageRating,
    this.isVerified = false,
    required this.createdAt,
  });

  /// Nom complet de l'utilisateur
  String get fullName => '$firstName $lastName';

  /// Initiales de l'utilisateur
  String get initials => '${firstName[0]}${lastName[0]}';

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
