class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;
  final String? relatedId; // ID de l'annonce ou proposition liée

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.relatedId,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    NotificationType? type,
    bool? isRead,
    String? relatedId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}

enum NotificationType {
  proposal,
  announcement,
  message,
  reminder,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.proposal:
        return 'Proposition';
      case NotificationType.announcement:
        return 'Annonce';
      case NotificationType.message:
        return 'Message';
      case NotificationType.reminder:
        return 'Rappel';
      case NotificationType.system:
        return 'Système';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.proposal:
        return '📋';
      case NotificationType.announcement:
        return '💼';
      case NotificationType.message:
        return '💬';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.system:
        return '⚙️';
    }
  }
}
