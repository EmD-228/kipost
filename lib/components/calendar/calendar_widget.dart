import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/controllers/calendar_controller.dart';
import 'package:kipost/models/calendar_event.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalendarController());

    return Obx(() => Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TableCalendar<CalendarEvent>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: controller.focusedDay,
          selectedDayPredicate: (day) => isSameDay(controller.selectedDay, day),
          eventLoader: controller.getEventsForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Colors.red.shade400),
            holidayTextStyle: TextStyle(color: Colors.red.shade400),
            selectedDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade300],
              ),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Colors.deepPurple.shade800,
              fontWeight: FontWeight.bold,
            ),
            markersMaxCount: 3,
            markerDecoration: BoxDecoration(
              color: Colors.orange.shade400,
              shape: BoxShape.circle,
            ),
            markerMargin: const EdgeInsets.symmetric(horizontal: 1),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronIcon: Icon(
              Iconsax.arrow_left_2,
              color: Colors.deepPurple,
              size: 20,
            ),
            rightChevronIcon: Icon(
              Iconsax.arrow_right_3,
              color: Colors.deepPurple,
              size: 20,
            ),
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            weekendStyle: TextStyle(
              color: Colors.red.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
          onDaySelected: controller.onDaySelected,
          onPageChanged: (focusedDay) {},
        ),
      ),
    ));
  }
}
