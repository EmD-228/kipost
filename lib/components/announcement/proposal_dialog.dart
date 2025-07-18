import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/services/proposal_service.dart';
import 'package:kipost/theme/app_colors.dart';

class ProposalDialog {
  static void show(BuildContext context, String announcementId) {
    final TextEditingController messageController = TextEditingController();
    final ProposalService proposalService = ProposalService();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 12,
            contentPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header avec gradient personnalisé
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Icône avec animation
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.onPrimary.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.onPrimary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Iconsax.send_1,
                            color: AppColors.onPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Candidature',
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Présentez votre profil pour cette mission',
                          style: TextStyle(
                            color: AppColors.onPrimary.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Contenu du formulaire
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre du formulaire
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Iconsax.edit,
                                color: AppColors.onPrimaryContainer,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Votre message de candidature',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Sous-titre avec conseils
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.infoContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.info.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.info_circle,
                                color: AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Présentez vos compétences et expériences pertinentes',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.onInfoContainer,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Champ de texte stylisé
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.outline.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: messageController,
                            maxLines: 6,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.onSurface,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Décrivez votre profil professionnel...\n\n'
                                  '• Vos compétences techniques\n'
                                  '• Votre expérience dans le domaine\n'
                                  '• Votre disponibilité\n'
                                  '• Pourquoi vous êtes le bon candidat',
                              hintStyle: TextStyle(
                                color: AppColors.onSurface.withOpacity(0.6),
                                fontSize: 14,
                                height: 1.4,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(20),
                              filled: true,
                              fillColor: AppColors.surface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Boutons d'action
                        KipostButton(
                          label: 'Envoyer ma candidature',
                          onPressed: () async {
                            if (messageController.text.trim().isNotEmpty) {
                              // Afficher un loading élégant
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      content: Container(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.primary,
                                                  ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Envoi en cours...',
                                              style: TextStyle(
                                                color: AppColors.onSurface
                                                    .withOpacity(0.8),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              );

                              try {
                                await proposalService.sendProposal(
                                  announcementId: announcementId,
                                  message: messageController.text.trim(),
                                );

                                Navigator.pop(context); // Fermer loading
                                Navigator.pop(context); // Fermer dialog

                                // Rafraîchir l'état de la page
                                (Get.context as Element).markNeedsBuild();

                                // Afficher un message de succès stylisé
                                Get.snackbar(
                                  'Candidature envoyée !',
                                  'Votre proposition a été transmise avec succès',
                                  backgroundColor: AppColors.success,
                                  colorText: AppColors.onSuccess,
                                  snackPosition: SnackPosition.TOP,
                                  duration: const Duration(seconds: 3),
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                  icon: const Icon(
                                    Iconsax.tick_circle,
                                    color: AppColors.onSuccess,
                                  ),
                                );
                              } catch (e) {
                                Navigator.pop(context); // Fermer loading

                                // Afficher un message d'erreur
                                Get.snackbar(
                                  'Erreur',
                                  'Impossible d\'envoyer la candidature',
                                  backgroundColor: AppColors.error,
                                  colorText: AppColors.onError,
                                  snackPosition: SnackPosition.TOP,
                                  duration: const Duration(seconds: 3),
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                  icon: const Icon(
                                    Iconsax.warning_2,
                                    color: AppColors.onError,
                                  ),
                                );
                              }
                            } else {
                              // Afficher un message de validation
                              Get.snackbar(
                                'Champ requis',
                                'Veuillez rédiger votre message de candidature',
                                backgroundColor: AppColors.warning,
                                colorText: AppColors.onWarning,
                                snackPosition: SnackPosition.TOP,
                                duration: const Duration(seconds: 2),
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                                icon: const Icon(
                                  Iconsax.info_circle,
                                  color: AppColors.onWarning,
                                ),
                              );
                            }
                          },
                          icon: Iconsax.user_add,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
