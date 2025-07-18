import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/theme/app_colors.dart';

class PaginationControls extends StatelessWidget {
  final bool isLoading;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final Map<String, dynamic>? paginationInfo;
  final int announcementsCount;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  const PaginationControls({
    super.key,
    required this.isLoading,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.paginationInfo,
    required this.announcementsCount,
    this.onPreviousPage,
    this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Indicateur de chargement pour la pagination
          if (isLoading && announcementsCount > 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),

          // Informations de pagination
          if (paginationInfo != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Page ${paginationInfo!['currentPage'] + 1} sur ${paginationInfo!['totalPages']}',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$announcementsCount sur ${paginationInfo!['totalCount']} annonces',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Boutons de navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bouton page précédente
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasPreviousPage && !isLoading ? onPreviousPage : null,
                  icon: const Icon(Iconsax.arrow_left_2),
                  label: const Text('Précédent'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Bouton page suivante
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: hasNextPage && !isLoading ? onNextPage : null,
                  icon: const Icon(Iconsax.arrow_right_3),
                  label: const Text('Suivant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 100), // Espace pour le bottom nav
        ],
      ),
    );
  }
}
