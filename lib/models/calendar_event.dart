class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final CalendarEventType type;
  final String? announcementId;
  final String? proposalId;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.announcementId,
    this.proposalId,
  });

  @override
  String toString() => title;
}

enum CalendarEventType {
  deadline,
  meeting,
  proposal,
  reminder,
}

extension CalendarEventTypeExtension on CalendarEventType {
  String get displayName {
    switch (this) {
      case CalendarEventType.deadline:
        return 'Échéance';
      case CalendarEventType.meeting:
        return 'Rendez-vous';
      case CalendarEventType.proposal:
        return 'Proposition';
      case CalendarEventType.reminder:
        return 'Rappel';
    }
  }

  String get icon {
    switch (this) {
      case CalendarEventType.deadline:
        return '⏰';
      case CalendarEventType.meeting:
        return '🤝';
      case CalendarEventType.proposal:
        return '📋';
      case CalendarEventType.reminder:
        return '🔔';
    }
  }
}
