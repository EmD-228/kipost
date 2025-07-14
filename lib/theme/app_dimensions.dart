import 'package:flutter/material.dart';

class AppDimensions {
  // Espacements de base
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Marges et paddings standardisés
  static const EdgeInsets paddingXs = EdgeInsets.all(spacingXs);
  static const EdgeInsets paddingSm = EdgeInsets.all(spacingSm);
  static const EdgeInsets paddingMd = EdgeInsets.all(spacingMd);
  static const EdgeInsets paddingLg = EdgeInsets.all(spacingLg);
  static const EdgeInsets paddingXl = EdgeInsets.all(spacingXl);

  // Paddings horizontaux
  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(horizontal: spacingXs);
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: spacingSm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: spacingMd);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: spacingLg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: spacingXl);

  // Paddings verticaux
  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(vertical: spacingXs);
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: spacingSm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: spacingMd);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: spacingLg);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: spacingXl);

  // Rayons de bordure
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;

  // BorderRadius standardisés
  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusXxl = BorderRadius.all(Radius.circular(radiusXxl));

  // Hauteurs de composants
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  static const double inputHeightSm = 40.0;
  static const double inputHeightMd = 48.0;
  static const double inputHeightLg = 56.0;

  static const double appBarHeight = 56.0;
  static const double tabBarHeight = 48.0;
  static const double bottomNavHeight = 80.0;

  // Largeurs
  static const double buttonMinWidth = 64.0;
  static const double fabSize = 56.0;
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double iconSizeXl = 48.0;

  // Élévations
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 12.0;

  // Épaisseurs de bordure
  static const double borderWidthThin = 0.5;
  static const double borderWidthMd = 1.0;
  static const double borderWidthThick = 2.0;

  // Dimensions spécifiques aux cartes
  static const double cardElevation = elevationSm;
  static const BorderRadius cardBorderRadius = borderRadiusLg;
  static const EdgeInsets cardPadding = EdgeInsets.all(spacingMd);
  static const EdgeInsets cardMargin = EdgeInsets.all(spacingSm);

  // Dimensions des avatars
  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 48.0;
  static const double avatarSizeLg = 64.0;
  static const double avatarSizeXl = 96.0;

  // Dimensions des thumbnails
  static const double thumbnailSizeSm = 48.0;
  static const double thumbnailSizeMd = 64.0;
  static const double thumbnailSizeLg = 96.0;
  static const double thumbnailSizeXl = 128.0;

  // Dimensions pour les listes
  static const double listItemHeight = 72.0;
  static const double listItemMinHeight = 48.0;
  static const double listItemMaxHeight = 96.0;

  // Dimensions pour les bottomsheets et dialogues
  static const double bottomSheetMaxHeight = 0.9;
  static const double dialogMaxWidth = 400.0;
  static const double dialogMinWidth = 280.0;

  // Tailles de police personnalisées
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;
  static const double fontSizeHeading = 24.0;
  static const double fontSizeTitle = 28.0;
  static const double fontSizeDisplay = 32.0;

  // Hauteurs de ligne
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  // Durées d'animation
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // Breakpoints pour le responsive design
  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  static const double breakpointLargeDesktop = 1440.0;

  // Méthodes utilitaires
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointMobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointMobile && width < breakpointDesktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointDesktop;
  }

  // Padding adaptatif basé sur la taille d'écran
  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return paddingMd;
    } else if (isTablet(context)) {
      return paddingLg;
    } else {
      return paddingXl;
    }
  }

  // Taille de police adaptative
  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.2;
    }
  }
}
