import 'package:flutter/material.dart';

class AppColors {
  // Couleur principale de l'application (orange Kipost)
  static const Color primary = Color(0xFFDD590F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFFDCC8);
  static const Color onPrimaryContainer = Color(0xFF3A1000);

  // Couleurs secondaires
  static const Color secondary = Color(0xFF104564);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFFDCC8);
  static const Color onSecondaryContainer = Color(0xFF2B160A);

  // Couleurs tertiaires
  static const Color tertiary = Color(0xFF646032);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFEBE4AA);
  static const Color onTertiaryContainer = Color(0xFF1F1D00);

  // Couleurs d'erreur
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  // Couleurs de surface (mode clair)
  static const Color surface = Color(0xFFFFFBFF);
  static const Color onSurface = Color(0xFF201A17);
  static const Color surfaceVariant = Color(0xFFF4DED4);
  static const Color onSurfaceVariant = Color(0xFF52443C);

  // Couleurs d'arrière-plan
  static const Color background = Color(0xFFFFFBFF);
  static const Color onBackground = Color(0xFF201A17);

  // Couleurs d'outline et autres
  static const Color outline = Color(0xFF84736B);
  static const Color outlineVariant = Color(0xFFD7C2B8);
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF362F2B);
  static const Color inverseOnSurface = Color(0xFFFBEEE8);
  static const Color inversePrimary = Color(0xFFFFB688);

  // Couleurs spécifiques aux dividers
  static const Color divider = Color(0xFFE5E5E5);

  // Couleurs pour le mode sombre
  static const Color darkBackground = Color(0xFF141218);
  static const Color darkSurface = Color(0xFF1F1B16);
  static const Color darkOnSurface = Color(0xFFEAE1DB);
  static const Color darkSurfaceVariant = Color(0xFF52443C);
  static const Color darkOnSurfaceVariant = Color(0xFFD7C2B8);

  // Couleurs sémantiques pour l'application
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  static const Color warning = Color(0xFFF57C00);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color onWarningContainer = Color(0xFFE65100);

  static const Color info = Color(0xFF1976D2);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFBBDEFB);
  static const Color onInfoContainer = Color(0xFF0D47A1);

  // Couleurs pour les statuts spécifiques à Kipost
  static const Color proposalPending = Color(0xFFFFA726); // Orange clair
  static const Color proposalAccepted = Color(0xFF66BB6A); // Vert
  static const Color proposalRejected = Color(0xFFEF5350); // Rouge
  static const Color proposalCancelled = Color(0xFF9E9E9E); // Gris

  static const Color workPlanned = Color(0xFF42A5F5); // Bleu
  static const Color workInProgress = Color(0xFFFF9800); // Orange
  static const Color workCompleted = Color(0xFF4CAF50); // Vert
  static const Color workCancelled = Color(0xFF757575); // Gris foncé

  static const Color announcementActive = Color(0xFF4CAF50); // Vert
  static const Color announcementPaused = Color(0xFFFF9800); // Orange
  static const Color announcementExpired = Color(0xFF9E9E9E); // Gris
  static const Color announcementCancelled = Color(0xFFE53935); // Rouge

  // Gradients pour des effets visuels
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF8A50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF8D7966)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFE53935)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Méthodes utilitaires pour obtenir des couleurs avec opacité
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Couleurs pour les différents états des propositions
  static Color getProposalStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'en_attente':
        return proposalPending;
      case 'accepted':
      case 'acceptée':
        return proposalAccepted;
      case 'rejected':
      case 'refusée':
        return proposalRejected;
      case 'cancelled':
      case 'annulée':
        return proposalCancelled;
      default:
        return onSurfaceVariant;
    }
  }

  // Couleurs pour les différents états des travaux
  static Color getWorkStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planned':
      case 'planifié':
        return workPlanned;
      case 'in_progress':
      case 'en_cours':
        return workInProgress;
      case 'completed':
      case 'terminé':
        return workCompleted;
      case 'cancelled':
      case 'annulé':
        return workCancelled;
      default:
        return onSurfaceVariant;
    }
  }

  // Couleurs pour les différents états des annonces
  static Color getAnnouncementStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return announcementActive;
      case 'paused':
      case 'en_pause':
        return announcementPaused;
      case 'expired':
      case 'expirée':
        return announcementExpired;
      case 'cancelled':
      case 'annulée':
        return announcementCancelled;
      default:
        return onSurfaceVariant;
    }
  }

  // Couleurs pour les niveaux de priorité
  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFF9800);
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityUrgent = Color(0xFF9C27B0);

  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
      case 'faible':
        return priorityLow;
      case 'medium':
      case 'moyenne':
        return priorityMedium;
      case 'high':
      case 'élevée':
        return priorityHigh;
      case 'urgent':
        return priorityUrgent;
      default:
        return priorityMedium;
    }
  }
}
