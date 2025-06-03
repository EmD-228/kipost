import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/home/coming_soon_tab.dart';

class ContractsTab extends StatelessWidget {
  const ContractsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonTab(
      icon: Iconsax.document,
      title: 'Contrats',
      description: 'Gérez vos contrats et suivez\nle statut de vos projets en cours.',
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
