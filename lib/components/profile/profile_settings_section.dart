import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/profile/profile_menu_item.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key});

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
              'Paramètres',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          ProfileMenuItem(
            icon: Iconsax.notification,
            title: 'Notifications',
            subtitle: 'Gérer vos préférences de notification',
            onTap: () {
              Get.snackbar(
                'Notifications',
                'Paramètres de notification à venir',
                backgroundColor: Colors.purple.shade100,
                colorText: Colors.purple.shade800,
              );
            },
          ),
          ProfileMenuItem(
            icon: Iconsax.security,
            title: 'Sécurité',
            subtitle: 'Mot de passe et authentification',
            onTap: () {
              Get.snackbar(
                'Sécurité',
                'Paramètres de sécurité à venir',
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade800,
              );
            },
          ),
          ProfileMenuItem(
            icon: Iconsax.info_circle,
            title: 'À propos',
            subtitle: 'Version de l\'app et informations légales',
            onTap: () {
              Get.snackbar(
                'À propos',
                'Kipost v1.0.0 - Votre plateforme de services',
                backgroundColor: Colors.grey.shade100,
                colorText: Colors.grey.shade800,
              );
            },
          ),
        ],
      ),
    );
  }
}
