import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';

class AnnouncementDescriptionSection extends StatelessWidget {
  final AnnouncementModel announcement;

  const AnnouncementDescriptionSection({
    super.key,
    required this.announcement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.document_text,
                  size: 20,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Description du projet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            announcement.description.capitalizeFirst!,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }
}
