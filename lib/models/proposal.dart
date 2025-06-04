import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kipost/models/announcement.dart';

class Proposal {
  final String id;
  final String announcementId;
  final String userId;
  final String userEmail;
  final String message;
  final DateTime createdAt;
  final String status; // exemple: en_attente, acceptée, refusée
  
  // Objet annonce complet
  final Announcement? announcement;

  Proposal({
    required this.id,
    required this.announcementId,
    required this.userId,
    required this.userEmail,
    required this.message,
    required this.createdAt,
    required this.status,
    this.announcement,
  });

  factory Proposal.fromMap(Map<String, dynamic> map, String docId) {
    print('🔍 DEBUG: Proposal.fromMap called with docId: $docId, map: $map');
    
    try {
      // Si les données de l'annonce sont présentes, créer l'objet Announcement
      Announcement? announcement;
      if (map['announcement'] != null) {
        announcement = Announcement.fromMap(map['announcement'], map['announcementId'] ?? '');
      }
      
      final proposal = Proposal(
        id: docId,
        announcementId: map['announcementId'] ?? '',
        userId: map['userId'] ?? '',
        userEmail: map['userEmail'] ?? '',
        message: map['message'] ?? '',
        createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
        status: map['status'] ?? 'en_attente',
        announcement: announcement,
      );
      
      print('🔍 DEBUG: Proposal created successfully: ${proposal.id} - ${proposal.message}');
      return proposal;
    } catch (e) {
      print('🔍 DEBUG: Error creating Proposal from map: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    final map = {
      'announcementId': announcementId,
      'userId': userId,
      'userEmail': userEmail,
      'message': message,
      'createdAt': createdAt,
      'status': status,
    };
    
    // Ajouter les données de l'annonce si disponibles
    if (announcement != null) {
      map['announcement'] = announcement!.toMap();
    }
    
    return map;
  }
}
