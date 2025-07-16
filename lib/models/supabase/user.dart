/// Modèle de données pour les utilisateurs (Supabase)
class UserSupabaseModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl;
  final Map<String, dynamic>? location;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSupabaseModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    this.location,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Nom complet de l'utilisateur
  String get fullName => '$firstName $lastName';

  /// Initiales de l'utilisateur
  String get initials => '${firstName[0]}${lastName[0]}';

  /// Ville de l'utilisateur (si location disponible)
  String? get city => location?['city'];

  /// Pays de l'utilisateur (si location disponible)
  String? get country => location?['country'];

  /// Latitude de l'utilisateur
  double? get latitude => location?['latitude'];

  /// Longitude de l'utilisateur
  double? get longitude => location?['longitude'];

  /// Factory constructor depuis une Map (Supabase)
  factory UserSupabaseModel.fromMap(Map<String, dynamic> map, String id) {
    return UserSupabaseModel(
      id: id,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatar_url'],
      location: map['location'],
      isVerified: map['is_verified'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// Conversion vers Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar_url': avatarUrl,
      'location': location,
      'is_verified': isVerified,
    };
  }

  /// Copie avec modifications
  UserSupabaseModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
    Map<String, dynamic>? location,
    bool? isVerified,
  }) {
    return UserSupabaseModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'UserSupabaseModel(id: $id, fullName: $fullName, email: $email, isVerified: $isVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSupabaseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
