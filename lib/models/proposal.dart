import 'package:cloud_firestore/cloud_firestore.dart';

class Proposal {
  final String id;
  final String announcementId;
  final String userId;
  final String userEmail;
  final String message;
  final DateTime createdAt;
  final String status; // exemple: en_attente, acceptée, refusée

  Proposal({
    required this.id,
    required this.announcementId,
    required this.userId,
    required this.userEmail,
    required this.message,
    required this.createdAt,
    required this.status,
  });

  factory Proposal.fromMap(Map<String, dynamic> map, String docId) {
    return Proposal(
      id: docId,
      announcementId: map['announcementId'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      message: map['message'] ?? '',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
      status: map['status'] ?? 'en_attente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'announcementId': announcementId,
      'userId': userId,
      'userEmail': userEmail,
      'message': message,
      'createdAt': createdAt,
      'status': status,
    };
  }
}
