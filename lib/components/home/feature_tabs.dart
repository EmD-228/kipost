import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/home/coming_soon_tab.dart';
import 'package:kipost/components/calendar/calendar_header.dart';
import 'package:kipost/components/calendar/calendar_widget.dart';
import 'package:kipost/components/calendar/event_list.dart';
import 'package:kipost/components/calendar/upcoming_events.dart';

class CalendrierTab extends StatelessWidget {
  const CalendrierTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          CalendarHeader(),
          CalendarWidget(),
          SizedBox(height: 8),
          EventList(),
          SizedBox(height: 8),
          UpcomingEvents(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonTab(
      icon: Iconsax.message,
      title: 'Messages',
      description: 'Communiquez directement avec\nvos clients et prestataires.',
    );
  }
}

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonTab(
      icon: Iconsax.notification,
      title: 'Notifications',
      description: 'Restez informé des dernières\nactivités sur vos annonces.',
    );
  }
}
