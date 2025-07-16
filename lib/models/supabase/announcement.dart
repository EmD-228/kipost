/// Modèle de données pour les annonces (Supabase)
class AnnouncementModel {
  final String id;
  final String clientId;
  final String title;
  final String description;
  final String category;
  final Map<String, dynamic> location;
  final double? budget;
  final bool isUrgent;
  final String status; // 'open', 'closed', 'in_progress', 'completed'
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relations
  final Map<String, dynamic>? client;

  AnnouncementModel({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.budget,
    this.isUrgent = false,
    this.status = 'open',
    required this.createdAt,
    required this.updatedAt,
    this.client,
  });

  /// Ville de l'annonce
  String? get city => location['city'];

  /// Pays de l'annonce
  String? get country => location['country'];

  /// Latitude de l'annonce
  double? get latitude => location['latitude'];

  /// Longitude de l'annonce
  double? get longitude => location['longitude'];

  /// Factory constructor depuis une Map (Supabase)
  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'],
      clientId: map['client_id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? {},
      budget: map['budget']?.toDouble(),
      isUrgent: map['is_urgent'] ?? false,
      status: map['status'] ?? 'open',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      client: map['client'],
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
      'is_urgent': isUrgent,
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
    bool? isUrgent,
    String? status,
  }) {
    return AnnouncementModel(
      id: id,
      clientId: clientId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      budget: budget ?? this.budget,
      isUrgent: isUrgent ?? this.isUrgent,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      client: client,
    );
  }

  @override
  String toString() {
    return 'AnnouncementModel(id: $id, title: $title, category: $category, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnnouncementModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
