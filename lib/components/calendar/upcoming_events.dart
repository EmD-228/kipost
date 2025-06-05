import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/controllers/calendar_controller.dart';
import 'package:kipost/models/calendar_event.dart';
import 'package:intl/intl.dart';

class UpcomingEvents extends StatelessWidget {
  const UpcomingEvents({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CalendarController>();

    return Obx(() {
      final upcomingEvents = controller.getUpcomingEvents();

      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.clock,
                    color: Colors.orange.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Événements à venir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${upcomingEvents.length}',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (upcomingEvents.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Iconsax.calendar_tick,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun événement à venir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: upcomingEvents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final event = upcomingEvents[index];
                  return _buildUpcomingEventCard(event);
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildUpcomingEventCard(CalendarEvent event) {
    final now = DateTime.now();
    final difference = event.date.difference(now);
    final daysUntil = difference.inDays;
    final hoursUntil = difference.inHours;

    String timeUntil;
    if (daysUntil > 0) {
      timeUntil = '$daysUntil jour${daysUntil > 1 ? 's' : ''}';
    } else if (hoursUntil > 0) {
      timeUntil = '$hoursUntil heure${hoursUntil > 1 ? 's' : ''}';
    } else {
      timeUntil = 'Bientôt';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getEventColor(event.type),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                event.type.icon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE d MMM', 'fr_FR').format(event.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getUrgencyColor(daysUntil).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              timeUntil,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getUrgencyColor(daysUntil),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.deadline:
        return Colors.red.shade400;
      case CalendarEventType.meeting:
        return Colors.blue.shade400;
      case CalendarEventType.proposal:
        return Colors.green.shade400;
      case CalendarEventType.reminder:
        return Colors.orange.shade400;
    }
  }

  Color _getUrgencyColor(int daysUntil) {
    if (daysUntil <= 1) {
      return Colors.red.shade600;
    } else if (daysUntil <= 3) {
      return Colors.orange.shade600;
    } else {
      return Colors.green.shade600;
    }
  }
}
