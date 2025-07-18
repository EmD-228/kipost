import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:kipost/utils/app_status.dart';

class AnnouncementHeader extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementHeader({
    super.key,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre principal
          Text(
            announcement.title.capitalizeFirst!,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Statut avec badge coloré
          Text(
            'Publié le ${_formatDate(announcement.createdAt)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  List<Color> _getStatusColors(String status) {
    switch (status) {
      case AnnouncementStatus.active:
        return [Colors.green, Colors.green.shade400];
      case AnnouncementStatus.completed:
        return [Colors.blue, Colors.blue.shade400];
      case AnnouncementStatus.paused:
        return [Colors.orange, Colors.orange.shade400];
      case AnnouncementStatus.cancelled:
        return [Colors.red, Colors.red.shade400];
      case AnnouncementStatus.expired:
        return [Colors.grey, Colors.grey.shade400];
      default:
        return [Colors.grey, Colors.grey.shade400];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AnnouncementStatus.active:
        return Iconsax.tick_circle;
      case AnnouncementStatus.completed:
        return Iconsax.user_tick;
      case AnnouncementStatus.paused:
        return Iconsax.pause_circle;
      case AnnouncementStatus.cancelled:
        return Iconsax.close_circle;
      case AnnouncementStatus.expired:
        return Iconsax.timer;
      default:
        return Iconsax.info_circle;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
