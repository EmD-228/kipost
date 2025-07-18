import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/text/app_text.dart';
import 'package:kipost/models/supabase/supabase_models.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementCard({
    super.key,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOpen = announcement.status == 'active';
    final DateTime createdAt = announcement.createdAt;
    final String timeAgo = _getTimeAgo(createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed('/announcement-detail', arguments: announcement);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec avatar et statut
              _buildHeader(isOpen, timeAgo),

              const SizedBox(height: 12),

              // Titre
              Text(
                announcement.title.capitalizeFirst ?? announcement.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 5),

              // Description
              AppText.bodySmall(announcement.description.capitalizeFirst ?? announcement.description),

              const SizedBox(height: 12),

              // Informations supplémentaires
              _buildCategoryAndLocation(),

              const SizedBox(height: 12),

              // Budget et urgence
              _buildBudgetAndUrgency(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isOpen, String timeAgo) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(
            announcement.client?.avatarUrl ??
                'https://avatar.iran.liara.run/public/33',
          ),
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${announcement.client?.firstName ?? ''} ${announcement.client?.lastName ?? ''}'.trim().isNotEmpty
                    ? '${announcement.client?.firstName ?? ''} ${announcement.client?.lastName ?? ''}'.trim()
                    : 'Utilisateur anonyme',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isOpen
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOpen ? Iconsax.clock : Iconsax.lock_1,
                size: 12,
                color: isOpen ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                isOpen ? 'Ouverte' : 'Fermée',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isOpen ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAndLocation() {
    return Row(
      children: [
        // Catégorie avec icône
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.category,
                size: 12,
                color: Colors.blue,
              ),
              const SizedBox(width: 4),
              Text(
                announcement.category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Localisation
        Icon(Iconsax.location, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            announcement.location['city']?.toString() ?? 'Non spécifié',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetAndUrgency() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (announcement.budget != null)
          Row(
            children: [
              Icon(
                Iconsax.wallet_3,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${announcement.budget!.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          )
        else
          const SizedBox(),
        
        // Urgence
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getUrgencyColor(announcement.urgency).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            announcement.urgency,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getUrgencyColor(announcement.urgency),
            ),
          ),
        ),
      ],
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'modéré':
        return Colors.orange;
      case 'faible':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}
