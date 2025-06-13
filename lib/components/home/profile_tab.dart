import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/controllers/auth_controller.dart';
import 'package:kipost/app_route.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // En-tête du profil
            Container(
              padding: const EdgeInsets.all(24),
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
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.user,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nom et email
                  Obx(
                    () => Column(
                      children: [
                        Text(
                          'Utilisateur',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          authController.firebaseUser.value?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Statistiques
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        '12',
                        'Annonces',
                        Iconsax.briefcase,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        '8',
                        'Propositions',
                        Iconsax.note_2,
                        Colors.green,
                      ),
                      _buildStatCard(
                        '3',
                        'En cours',
                        Iconsax.clock,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Options du profil
            _buildOptionsSection(),

            const SizedBox(height: 20),

            // Paramètres
            _buildSettingsSection(),

            const SizedBox(height: 20),

            // Bouton de déconnexion
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          _buildMenuItem(
            icon: Iconsax.edit,
            title: 'Modifier le profil',
            subtitle: 'Nom, photo, informations personnelles',
            onTap: () {
              Get.toNamed(AppRoutes.profile);
            },
          ),
          _buildMenuItem(
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
          _buildMenuItem(
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

  Widget _buildSettingsSection() {
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
          _buildMenuItem(
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
          _buildMenuItem(
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
          _buildMenuItem(
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.grey.shade600, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Get.dialog(
            AlertDialog(
              title: const Text('Déconnexion'),
              content: const Text(
                'Êtes-vous sûr de vouloir vous déconnecter ?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    AuthController.to.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Déconnexion'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.logout, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Se déconnecter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
