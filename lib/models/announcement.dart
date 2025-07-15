import 'package:cloud_firestore/cloud_firestore.dart';
import 'category.dart';
import 'urgency_level.dart';
import 'user.dart';
import '../utils/app_status.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final Category category;
  final UrgencyLevel urgencyLevel;
  final String location;
  final String status;
  final String creatorId;
  final String creatorEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> proposalIds; // Liste des IDs des propositions
  final double? price; // Prix/Budget estimé (optionnel)

  // Objets relationnels
  final UserModel? creatorProfile; // Profil du créateur de l'annonce

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.urgencyLevel,
    required this.location,
    required this.status,
    required this.creatorId,
    required this.creatorEmail,
    required this.createdAt,
    required this.updatedAt,
    this.proposalIds = const [],
    this.price,
    this.creatorProfile,
  });

  factory Announcement.fromMap(Map<String, dynamic> map, String docId) {
    return Announcement(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: Category.fromMap(map['category'] ?? ''),
      urgencyLevel: UrgencyLevel.fromMap(map['urgencyLevel'] ?? ''),
      location: map['location'] ?? '',
      status: map['status'] ?? AnnouncementStatus.active,
      creatorId: map['creatorId'] ?? '',
      creatorEmail: map['creatorEmail'] ?? '',
      createdAt:
          (map['createdAt'] != null)
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          (map['updatedAt'] != null)
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
      proposalIds: List<String>.from(map['proposalIds'] ?? []),
      price: map['price']?.toDouble(),
      creatorProfile:
          map['creatorProfile'] != null
              ? UserModel.fromMap(map['creatorProfile'], map['creatorId'] ?? '')
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category.id,
      'urgencyLevel': urgencyLevel.id,
      'location': location,
      'status': status,
      'creatorId': creatorId,
      'creatorEmail': creatorEmail,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'proposalIds': proposalIds,
      'price': price,
      'creatorProfile': creatorProfile?.toMap(),
    };
  }

  // Méthode pour créer une copie avec des modifications
  Announcement copyWith({
    String? id,
    String? title,
    String? description,
    Category? category,
    UrgencyLevel? urgencyLevel,
    String? location,
    String? status,
    String? creatorId,
    String? creatorEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? proposalIds,
    double? price,
    UserModel? creatorProfile,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      location: location ?? this.location,
      status: status ?? this.status,
      creatorId: creatorId ?? this.creatorId,
      creatorEmail: creatorEmail ?? this.creatorEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      proposalIds: proposalIds ?? this.proposalIds,
      price: price ?? this.price,
      creatorProfile: creatorProfile ?? this.creatorProfile,
    );
  }

  // Méthodes utilitaires
  bool get isOpen => status == AnnouncementStatus.active;
  bool get isClosed => status == AnnouncementStatus.cancelled || 
                       status == AnnouncementStatus.completed || 
                       status == AnnouncementStatus.expired;
  bool get isPaused => status == AnnouncementStatus.paused;
  int get proposalCount => proposalIds.length;

  // Créer une annonce avec des données de test
  static Announcement createMockAnnouncement({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    String? status,
    String? location,
    String? budget,
    String? creatorName,
    String? creatorAvatar,
    int? proposalCount,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    final category =
        Category.getCategoryById(categoryId ?? 'aide_menagere') ??
        Category.getCategoryById('autre')!;
    final urgencyLevel = UrgencyLevel.getUrgencyById('modere')!;

    final creatorProfile = UserModel(
      // userType: "",
      id: 'mock_creator_${id ?? 'default'}',
      name: creatorName ?? 'Akosua Gyasi',
      email: 'creator@example.com',
      avatar: creatorAvatar ?? 'https://avatar.iran.liara.run/public/33',
      createdAt: now,
      updatedAt: now,
    );

    return Announcement(
      id: id ?? 'mock_announcement',
      title: title ?? 'Service de ménage hebdomadaire',
      description:
          description ??
          'Recherche aide ménagère fiable pour entretien hebdomadaire d\'un appartement 3 pièces.',
      category: category,
      urgencyLevel: urgencyLevel,
      location: location ?? 'Yopougon, Abidjan',
      status: status ?? AnnouncementStatus.active,
      creatorId: creatorProfile.id,
      creatorEmail: creatorProfile.email,
      createdAt: createdAt ?? now,
      updatedAt: now,
      price: double.tryParse(budget ?? '40000'),
      creatorProfile: creatorProfile,
      proposalIds: List.generate(
        proposalCount ?? 0,
        (index) => 'proposal_$index',
      ),
    );
  }

  @override
  String toString() {
    return 'Announcement(id: $id, title: $title, status: $status, proposalCount: $proposalCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Announcement && other.id == id && other.title == title;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode;
  }
}
