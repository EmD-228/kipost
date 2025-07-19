import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';

/// Widget pour afficher les informations de l'annonce associée à une proposition
class AnnouncementInfoCard extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementInfoCard({
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.task,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Annonce concernée',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            announcement.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            announcement.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Iconsax.category,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                announcement.category,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              if (announcement.city != null) ...[
                Icon(
                  Iconsax.location,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  announcement.city!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
          if (announcement.budget != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Iconsax.wallet,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Budget: ${announcement.budget!.toStringAsFixed(0)} €',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
