import 'package:get/get.dart';
import 'package:kipost/models/calendar_event.dart';

class CalendarController extends GetxController {
  static CalendarController get to => Get.find();

  final RxList<CalendarEvent> _events = <CalendarEvent>[].obs;
  final Rx<DateTime> _selectedDay = DateTime.now().obs;
  final Rx<DateTime> _focusedDay = DateTime.now().obs;

  List<CalendarEvent> get events => _events;
  DateTime get selectedDay => _selectedDay.value;
  DateTime get focusedDay => _focusedDay.value;

  @override
  void onInit() {
    super.onInit();
    _loadMockEvents();
  }

  void _loadMockEvents() {
    final now = DateTime.now();
    _events.assignAll([
      CalendarEvent(
        id: '1',
        title: 'Remise de proposition',
        description: 'Proposition pour développement site web',
        date: now.add(const Duration(days: 2)),
        type: CalendarEventType.deadline,
        announcementId: 'ann1',
      ),
      CalendarEvent(
        id: '2',
        title: 'Entretien client',
        description: 'Discussion projet mobile app',
        date: now.add(const Duration(days: 5)),
        type: CalendarEventType.meeting,
        announcementId: 'ann2',
      ),
      CalendarEvent(
        id: '3',
        title: 'Nouvelle proposition reçue',
        description: 'Proposition de Jean Dupont',
        date: now.subtract(const Duration(days: 1)),
        type: CalendarEventType.proposal,
        proposalId: 'prop1',
      ),
      CalendarEvent(
        id: '4',
        title: 'Suivi projet',
        description: 'Point hebdomaire sur le projet e-commerce',
        date: now.add(const Duration(days: 7)),
        type: CalendarEventType.reminder,
      ),
      CalendarEvent(
        id: '5',
        title: 'Présentation finale',
        description: 'Livraison du projet de refonte',
        date: now.add(const Duration(days: 14)),
        type: CalendarEventType.deadline,
        announcementId: 'ann3',
      ),
      CalendarEvent(
        id: '6',
        title: 'Réunion équipe',
        description: 'Planning des nouveaux projets',
        date: now.add(const Duration(days: 3)),
        type: CalendarEventType.meeting,
      ),
    ]);
  }

  List<CalendarEvent> getEventsForDay(DateTime day) {
    return _events.where((event) {
      return event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day;
    }).toList();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay.value = selectedDay;
    _focusedDay.value = focusedDay;
  }

  void addEvent(CalendarEvent event) {
    _events.add(event);
  }

  void removeEvent(String eventId) {
    _events.removeWhere((event) => event.id == eventId);
  }

  List<CalendarEvent> getUpcomingEvents({int limit = 5}) {
    final now = DateTime.now();
    return _events
        .where((event) => event.date.isAfter(now))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date))
      ..take(limit);
  }
}
