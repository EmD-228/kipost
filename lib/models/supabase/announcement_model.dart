import 'profile_model.dart';

/// Modèle de données pour les annonces Supabase
class AnnouncementModel {
  final String id;
  final String clientId;
  final String title;
  final String description;
  final String category;
  final Map<String, dynamic> location;
  final double? budget;
  final String urgency;
  final String status;
  final DateTime createdAt;
  final ProfileModel? client;

  AnnouncementModel({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.budget,
    this.urgency = 'Modéré',
    this.status = 'active',
    required this.createdAt,
    this.client,
  });

  /// Ville de l'annonce
  String? get city => location['city'];

  /// Pays de l'annonce
  String? get country => location['country'];

  /// Latitude de l'annonce
  double? get latitude => location['latitude']?.toDouble();

  /// Longitude de l'annonce
  double? get longitude => location['longitude']?.toDouble();

  /// Nom complet du client
  String? get clientName => client?.fullName;

  /// Avatar du client
  String? get clientAvatar => client?.avatarUrl;

  /// Vérification si l'annonce est active
  bool get isActive => status == 'active';

  /// Vérification si l'annonce est urgente
  bool get isUrgent => urgency == 'Urgent';

  /// Factory constructor depuis une Map (Supabase)
  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    ProfileModel? client;
    if (map['client'] != null) {
      client = ProfileModel.fromMap(Map<String, dynamic>.from(map['client']));
    }

    return AnnouncementModel(
      id: map['id'],
      clientId: map['client_id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: Map<String, dynamic>.from(map['location'] ?? {}),
      budget: map['budget']?.toDouble(),
      urgency: map['urgency'] ?? 'Modéré',
      status: map['status'] ?? 'active',
      createdAt: DateTime.parse(map['created_at']),
      client: client,
    );
  }

  /// Conversion vers Map pour Supabase
  Map<String, dynamic> toMap() {
    return {
      'client_id': clientId,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'budget': budget,
      'urgency': urgency,
      'status': status,
    };
  }

  /// Copie avec modifications
  AnnouncementModel copyWith({
    String? title,
    String? description,
    String? category,
    Map<String, dynamic>? location,
    double? budget,
    String? urgency,
    String? status,
    ProfileModel? client,
  }) {
    return AnnouncementModel(
      id: id,
      clientId: clientId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      createdAt: createdAt,
      client: client ?? this.client,
    );
  }

  @override
  String toString() {
    return 'AnnouncementModel(id: $id, title: $title, category: $category, status: $status, urgency: $urgency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnnouncementModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
