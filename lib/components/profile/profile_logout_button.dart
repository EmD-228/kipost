import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/services/auth_service.dart';
import 'package:kipost/app_route.dart';

class ProfileLogoutButton extends StatelessWidget {
  final AuthService authService;

  const ProfileLogoutButton({
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () async {
                    Get.back();
                    try {
                      await authService.signOut();
                      // Naviguer vers l'écran de connexion
                      Get.offAllNamed(AppRoutes.auth);
                    } catch (e) {
                      Get.snackbar(
                        'Erreur',
                        'Impossible de se déconnecter: ${e.toString()}',
                        backgroundColor: Colors.red.shade100,
                        colorText: Colors.red.shade800,
                      );
                    }
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
