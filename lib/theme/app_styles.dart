import 'package:flutter/material.dart';
import 'package:kipost/theme/app_colors.dart';
import 'package:kipost/theme/app_dimensions.dart';

class AppStyles {
  // Styles pour les cartes
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: AppDimensions.cardBorderRadius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: const Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration cardDecorationDark = BoxDecoration(
    color: AppColors.darkSurface,
    borderRadius: AppDimensions.cardBorderRadius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        offset: const Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );

  // Styles pour les boutons
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: AppDimensions.elevationSm,
    padding: AppDimensions.paddingMd,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusLg,
    ),
    minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeightMd),
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    foregroundColor: AppColors.onSecondary,
    elevation: AppDimensions.elevationSm,
    padding: AppDimensions.paddingMd,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusLg,
    ),
    minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeightMd),
  );

  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: AppDimensions.borderWidthMd),
    padding: AppDimensions.paddingMd,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusLg,
    ),
    minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeightMd),
  );

  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: AppDimensions.paddingMd,
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusLg,
    ),
    minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeightMd),
  );

  // Styles pour les champs de saisie
  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusLg,
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusLg,
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusLg,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusLg,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusLg,
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: AppDimensions.paddingMd,
      filled: true,
      fillColor: AppColors.surface,
    );
  }

  // Styles pour les conteneurs avec statut
  static BoxDecoration getStatusDecoration(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'proposal':
      case 'proposition':
        statusColor = AppColors.proposalPending;
        break;
      case 'work':
      case 'travail':
        statusColor = AppColors.workPlanned;
        break;
      case 'announcement':
      case 'annonce':
        statusColor = AppColors.announcementActive;
        break;
      case 'completed':
      case 'terminé':
        statusColor = AppColors.success;
        break;
      case 'pending':
      case 'en_attente':
        statusColor = AppColors.warning;
        break;
      case 'cancelled':
      case 'annulé':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.onSurfaceVariant;
    }

    return BoxDecoration(
      color: statusColor.withOpacity(0.1),
      border: Border.all(color: statusColor.withOpacity(0.3)),
      borderRadius: AppDimensions.borderRadiusSm,
    );
  }

  // Styles pour les badges de statut
  static BoxDecoration statusBadgeDecoration(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'proposal':
      case 'proposition':
        statusColor = AppColors.proposalPending;
        break;
      case 'work':
      case 'travail':
        statusColor = AppColors.workPlanned;
        break;
      case 'announcement':
      case 'annonce':
        statusColor = AppColors.announcementActive;
        break;
      case 'completed':
      case 'terminé':
        statusColor = AppColors.success;
        break;
      case 'pending':
      case 'en_attente':
        statusColor = AppColors.warning;
        break;
      case 'cancelled':
      case 'annulé':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.onSurfaceVariant;
    }

    return BoxDecoration(
      color: statusColor,
      borderRadius: AppDimensions.borderRadiusSm,
    );
  }

  // Styles pour les avatars
  static BoxDecoration avatarDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.outline, width: 1),
  );

  // Styles pour les dividers
  static Widget divider = Divider(
    color: AppColors.outline.withOpacity(0.3),
    thickness: 0.5,
    height: 1,
  );

  static Widget verticalDivider = VerticalDivider(
    color: AppColors.outline.withOpacity(0.3),
    thickness: 0.5,
    width: 1,
  );

  // Styles pour les loading indicators
  static Widget loadingIndicator = const CircularProgressIndicator(
    color: AppColors.primary,
    strokeWidth: 2,
  );

  static Widget smallLoadingIndicator = const SizedBox(
    width: 16,
    height: 16,
    child: CircularProgressIndicator(
      color: AppColors.primary,
      strokeWidth: 2,
    ),
  );

  // Styles pour les snackbars
  static SnackBarThemeData snackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.surface,
    contentTextStyle: const TextStyle(color: AppColors.onSurface),
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusLg,
    ),
    behavior: SnackBarBehavior.floating,
  );

  // Styles pour les bottom sheets
  static ShapeBorder bottomSheetShape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AppDimensions.radiusXl),
    ),
  );

  // Styles pour les dialogues
  static ShapeBorder dialogShape = RoundedRectangleBorder(
    borderRadius: AppDimensions.borderRadiusXl,
  );

  // Styles pour les chips
  static ChipThemeData chipTheme = ChipThemeData(
    backgroundColor: AppColors.surface,
    selectedColor: AppColors.primary.withOpacity(0.2),
    labelStyle: const TextStyle(color: AppColors.onSurface),
    side: const BorderSide(color: AppColors.outline),
    shape: RoundedRectangleBorder(
      borderRadius: AppDimensions.borderRadiusLg,
    ),
  );

  // Gradients
  static LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient secondaryGradient = LinearGradient(
    colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  // Méthodes utilitaires pour créer des styles dynamiques
  static BoxDecoration customCardDecoration({
    Color? color,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: borderRadius ?? AppDimensions.cardBorderRadius,
      boxShadow: boxShadow ?? cardShadow,
      border: border,
    );
  }

  static ButtonStyle customButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    Size? minimumSize,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: AppDimensions.elevationSm,
      padding: padding ?? AppDimensions.paddingMd,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? AppDimensions.borderRadiusLg,
      ),
      minimumSize: minimumSize ?? const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeightMd),
    );
  }
}
