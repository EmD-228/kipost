import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String creatorId;
  final String creatorEmail;
  final DateTime createdAt;
  final List<String> proposalIds; // Liste des IDs des propositions

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.creatorId,
    required this.creatorEmail,
    required this.createdAt,
    this.proposalIds = const [],
  });

  factory Announcement.fromMap(Map<String, dynamic> map, String docId) {
    return Announcement(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      status: map['status'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creatorEmail: map['creatorEmail'] ?? '',
      createdAt: (map['createdAt'] != null)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      proposalIds: List<String>.from(map['proposalIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'status': status,
      'creatorId': creatorId,
      'creatorEmail': creatorEmail,
      'createdAt': createdAt,
      'proposalIds': proposalIds,
    };
  }
}