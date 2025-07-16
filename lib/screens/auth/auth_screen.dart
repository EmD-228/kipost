import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/app_route.dart';
import 'package:kipost/services/auth_service.dart';
import 'package:kipost/theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  /// Vérifie si l'utilisateur est déjà connecté
  Future<void> _checkAuthenticationStatus() async {
    try {
      // Attendre un petit délai pour l'animation de chargement
      await Future.delayed(const Duration(milliseconds: 5000));
      
      // Vérifier si l'utilisateur est connecté
      final isAuthenticated = _authService.isAuthenticated;
      
      if (mounted) {
        if (isAuthenticated) {
          // Utilisateur connecté → rediriger vers l'accueil
          Get.offAllNamed(AppRoutes.home);
        } else {
          // Utilisateur non connecté → rediriger vers l'authentification
          Get.offAllNamed(AppRoutes.authWelcome);
        }
      }
    } catch (e) {
      // En cas d'erreur, rediriger vers l'authentification
      if (mounted) {
        Get.offAllNamed(AppRoutes.authWelcome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.user_octagon,
                size: 60,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Vérification de l\'authentification...',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
