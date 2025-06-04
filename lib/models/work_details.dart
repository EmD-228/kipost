import 'package:cloud_firestore/cloud_firestore.dart';

class WorkDetails {
  final String id;
  final String proposalId;
  final String announcementId;
  final String clientId;
  final String providerId;
  final DateTime scheduledDate;
  final String scheduledTime; // Format: "14:30"
  final String workLocation;
  final String? additionalNotes;
  final String status; // 'planned', 'in_progress', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime? completedAt;

  WorkDetails({
    required this.id,
    required this.proposalId,
    required this.announcementId,
    required this.clientId,
    required this.providerId,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.workLocation,
    this.additionalNotes,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory WorkDetails.fromMap(Map<String, dynamic> map, String id) {
    return WorkDetails(
      id: id,
      proposalId: map['proposalId'] ?? '',
      announcementId: map['announcementId'] ?? '',
      clientId: map['clientId'] ?? '',
      providerId: map['providerId'] ?? '',
      scheduledDate: (map['scheduledDate'] as Timestamp).toDate(),
      scheduledTime: map['scheduledTime'] ?? '',
      workLocation: map['workLocation'] ?? '',
      additionalNotes: map['additionalNotes'],
      status: map['status'] ?? 'planned',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'proposalId': proposalId,
      'announcementId': announcementId,
      'clientId': clientId,
      'providerId': providerId,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'scheduledTime': scheduledTime,
      'workLocation': workLocation,
      'additionalNotes': additionalNotes,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  WorkDetails copyWith({
    String? id,
    String? proposalId,
    String? announcementId,
    String? clientId,
    String? providerId,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? workLocation,
    String? additionalNotes,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return WorkDetails(
      id: id ?? this.id,
      proposalId: proposalId ?? this.proposalId,
      announcementId: announcementId ?? this.announcementId,
      clientId: clientId ?? this.clientId,
      providerId: providerId ?? this.providerId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      workLocation: workLocation ?? this.workLocation,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
