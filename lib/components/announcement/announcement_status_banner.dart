import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:kipost/utils/app_status.dart';

class AnnouncementStatusBanner extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementStatusBanner({
    super.key,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    final statusColors = _getStatusColors(announcement.status);
    final statusIcon = _getStatusIcon(announcement.status);
    final statusLabel = AnnouncementStatus.getLabel(announcement.status);
    
    // Définir le message et l'icône selon le statut
    String message;
    IconData leadingIcon;
    Color backgroundColor;
    Color textColor;
    Color iconColor;
    
    switch (announcement.status) {
      case AnnouncementStatus.active:
        message = 'Cette annonce est ouverte aux candidatures';
        leadingIcon = Iconsax.info_circle;
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        iconColor = Colors.green.shade600;
        break;
      case AnnouncementStatus.completed:
        message = 'Cette annonce a été terminée avec succès';
        leadingIcon = Iconsax.tick_circle;
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade800;
        iconColor = Colors.blue.shade600;
        break;
      case AnnouncementStatus.paused:
        message = 'Cette annonce est temporairement en pause';
        leadingIcon = Iconsax.pause_circle;
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade800;
        iconColor = Colors.orange.shade600;
        break;
      case AnnouncementStatus.cancelled:
        message = 'Cette annonce a été annulée';
        leadingIcon = Iconsax.close_circle;
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        iconColor = Colors.red.shade600;
        break;
      case AnnouncementStatus.expired:
        message = 'Cette annonce a expiré';
        leadingIcon = Iconsax.timer;
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade800;
        iconColor = Colors.grey.shade600;
        break;
      default:
        message = 'Statut de l\'annonce inconnu';
        leadingIcon = Iconsax.info_circle;
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade800;
        iconColor = Colors.grey.shade600;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône d'information
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              leadingIcon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Contenu textuel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Badge de statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: statusColors),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
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
}
