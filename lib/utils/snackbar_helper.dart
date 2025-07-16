import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../theme/app_colors.dart';

/// Helper pour afficher des snackbars standardisées dans l'application
class SnackbarHelper {
  // Position par défaut des snackbars
  static const SnackPosition _defaultPosition = SnackPosition.TOP;
  
  // Durée par défaut d'affichage
  static const Duration _defaultDuration = Duration(seconds: 4);
  
  // Marge par défaut
  static const EdgeInsets _defaultMargin = EdgeInsets.all(16);

  /// Affiche une snackbar de succès
  static void showSuccess({
    required String title,
    required String message,
    SnackPosition position = _defaultPosition,
    Duration duration = _defaultDuration,
    VoidCallback? onTap,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.successContainer,
      colorText: AppColors.onSuccessContainer,
      snackPosition: position,
      duration: duration,
      margin: _defaultMargin,
      borderRadius: 12,
      icon: Icon(
        Iconsax.tick_circle,
        color: AppColors.success,
        size: 24,
      ),
      shouldIconPulse: false,
      onTap: onTap != null ? (_) => onTap() : null,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.fastOutSlowIn,
    );
  }

  /// Affiche une snackbar d'erreur
  static void showError({
    required String title,
    required String message,
    SnackPosition position = _defaultPosition,
    Duration duration = _defaultDuration,
    VoidCallback? onTap,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.errorContainer,
      colorText: AppColors.onErrorContainer,
      snackPosition: position,
      duration: duration,
      margin: _defaultMargin,
      borderRadius: 12,
      icon: Icon(
        Iconsax.warning_2,
        color: AppColors.error,
        size: 24,
      ),
      shouldIconPulse: false,
      onTap: onTap != null ? (_) => onTap() : null,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.fastOutSlowIn,
    );
  }

  /// Affiche une snackbar d'avertissement
  static void showWarning({
    required String title,
    required String message,
    SnackPosition position = _defaultPosition,
    Duration duration = _defaultDuration,
    VoidCallback? onTap,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.warningContainer,
      colorText: AppColors.onWarningContainer,
      snackPosition: position,
      duration: duration,
      margin: _defaultMargin,
      borderRadius: 12,
      icon: Icon(
        Iconsax.info_circle,
        color: AppColors.warning,
        size: 24,
      ),
      shouldIconPulse: false,
      onTap: onTap != null ? (_) => onTap() : null,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.fastOutSlowIn,
    );
  }

  /// Affiche une snackbar d'information
  static void showInfo({
    required String title,
    required String message,
    SnackPosition position = _defaultPosition,
    Duration duration = _defaultDuration,
    VoidCallback? onTap,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.infoContainer,
      colorText: AppColors.onInfoContainer,
      snackPosition: position,
      duration: duration,
      margin: _defaultMargin,
      borderRadius: 12,
      icon: Icon(
        Iconsax.information,
        color: AppColors.info,
        size: 24,
      ),
      shouldIconPulse: false,
      onTap: onTap != null ? (_) => onTap() : null,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.fastOutSlowIn,
    );
  }

  /// Affiche une snackbar personnalisée
  static void showCustom({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    IconData? iconData,
    Color? iconColor,
    SnackPosition position = _defaultPosition,
    Duration duration = _defaultDuration,
    VoidCallback? onTap,
    bool isDismissible = true,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      snackPosition: position,
      duration: duration,
      margin: _defaultMargin,
      borderRadius: 12,
      icon: iconData != null
          ? Icon(
              iconData,
              color: iconColor ?? textColor,
              size: 24,
            )
          : null,
      shouldIconPulse: false,
      onTap: onTap != null ? (_) => onTap() : null,
      isDismissible: isDismissible,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.fastOutSlowIn,
    );
  }

  /// Méthodes de convenance avec messages prédéfinis

  /// Succès d'authentification
  static void showAuthSuccess({String? customMessage}) {
    showSuccess(
      title: 'Succès',
      message: customMessage ?? 'Opération réalisée avec succès',
    );
  }

  /// Erreur d'authentification
  static void showAuthError({String? customMessage}) {
    showError(
      title: 'Erreur',
      message: customMessage ?? 'Une erreur est survenue lors de l\'authentification',
    );
  }

  /// Erreur de validation
  static void showValidationError({required String field}) {
    showError(
      title: 'Erreur de validation',
      message: 'Veuillez vérifier le champ : $field',
    );
  }

  /// Erreur de connexion réseau
  static void showNetworkError() {
    showError(
      title: 'Erreur de connexion',
      message: 'Vérifiez votre connexion internet et réessayez',
      duration: const Duration(seconds: 6),
    );
  }

  /// Information de chargement
  static void showLoading({String? message}) {
    showInfo(
      title: 'Chargement',
      message: message ?? 'Opération en cours...',
      duration: const Duration(seconds: 2),
    );
  }

  /// Confirmation d'action
  static void showActionConfirmed({required String action}) {
    showSuccess(
      title: 'Confirmé',
      message: '$action effectué avec succès',
    );
  }

  /// Avertissement de limite atteinte
  static void showLimitWarning({String? customMessage}) {
    showWarning(
      title: 'Limite atteinte',
      message: customMessage ?? 'Vous avez atteint la limite autorisée',
    );
  }

  /// Méthode pour fermer toutes les snackbars
  static void closeAll() {
    Get.closeAllSnackbars();
  }

  /// Méthode pour fermer la snackbar actuelle
  static void close() {
    Get.back();
  }
}
