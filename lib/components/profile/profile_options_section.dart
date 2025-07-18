import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/app_route.dart';
import 'package:kipost/components/profile/profile_menu_item.dart';

class ProfileOptionsSection extends StatelessWidget {
  final VoidCallback onProfileUpdated;

  const ProfileOptionsSection({
    super.key,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Mon compte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ProfileMenuItem(
            icon: Iconsax.edit,
            title: 'Modifier le profil',
            subtitle: 'Nom, photo, informations personnelles',
            onTap: () async {
              final result = await Get.toNamed(AppRoutes.profile);
              // Recharger le profil si des modifications ont été apportées
              if (result == true) {
                onProfileUpdated();
              }
            },
          ),
          ProfileMenuItem(
            icon: Iconsax.briefcase,
            title: 'Mes annonces',
            subtitle: 'Voir et gérer mes annonces publiées',
            onTap: () {
              // Get.toNamed(AppRoutes.myAnnouncements);
            },
          ),
          ProfileMenuItem(
            icon: Iconsax.card,
            title: 'Informations de paiement',
            subtitle: 'Méthodes de paiement et facturation',
            onTap: () {
              Get.snackbar(
                'Paiement',
                'Gestion des paiements à venir',
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade800,
              );
            },
          ),
          ProfileMenuItem(
            icon: Iconsax.star,
            title: 'Mes avis',
            subtitle: 'Consultez vos évaluations',
            onTap: () {
              Get.snackbar(
                'Avis',
                'Système d\'évaluation à venir',
                backgroundColor: Colors.yellow.shade100,
                colorText: Colors.yellow.shade800,
              );
            },
          ),
        ],
      ),
    );
  }
}
