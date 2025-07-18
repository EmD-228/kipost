import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:kipost/components/jobs/announcement_card.dart';

class AnnouncementsList extends StatelessWidget {
  final List<AnnouncementModel> announcements;
  final bool isLoading;
  final bool isEmpty;

  const AnnouncementsList({
    super.key,
    required this.announcements,
    required this.isLoading,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && announcements.isEmpty) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.search_normal,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune annonce trouvée',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Essayez de modifier vos critères de recherche',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == announcements.length - 1 ? 0 : 8,
            ),
            child: AnnouncementCard(announcement: announcements[index]),
          );
        },
        childCount: announcements.length,
      ),
    );
  }
}
