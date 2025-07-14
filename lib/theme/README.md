# Système de Thème Kipost

Ce dossier contient le système de thème complet pour l'application Kipost, basé sur Material Design 3.

## Structure des fichiers

- `app_theme.dart` - Configuration principale du thème (clair/sombre)
- `app_colors.dart` - Palette de couleurs complète avec couleurs sémantiques
- `app_dimensions.dart` - Dimensions, espacements et constantes de mise en page
- `app_styles.dart` - Styles prédéfinis pour les composants
- `theme.dart` - Fichier d'export principal
- `theme_example.dart` - Exemples d'utilisation du système de thème

## Utilisation

### Import simple
```dart
import 'package:kipost/theme/theme.dart';
```

### Configuration dans main.dart
```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
  // ...
)
```

## Couleurs

### Couleurs principales
- `AppColors.primary` - Orange principal (#DD590F)
- `AppColors.secondary` - Brun secondaire (#6F5B37)
- `AppColors.surface` - Surface (#FFFBFF)
- `AppColors.background` - Arrière-plan (#FFFBFF)

### Couleurs sémantiques
- `AppColors.success` - Vert pour les succès
- `AppColors.warning` - Orange pour les avertissements
- `AppColors.error` - Rouge pour les erreurs
- `AppColors.info` - Bleu pour les informations

### Couleurs de statut spécifiques
- **Propositions**: `proposalPending`, `proposalAccepted`, `proposalRejected`, `proposalCancelled`
- **Travaux**: `workPlanned`, `workInProgress`, `workCompleted`, `workCancelled`
- **Annonces**: `announcementActive`, `announcementPaused`, `announcementExpired`, `announcementCancelled`

## Dimensions

### Espacements
```dart
AppDimensions.spacingXs   // 4.0
AppDimensions.spacingSm   // 8.0
AppDimensions.spacingMd   // 16.0
AppDimensions.spacingLg   // 24.0
AppDimensions.spacingXl   // 32.0
AppDimensions.spacingXxl  // 48.0
```

### Paddings prédéfinis
```dart
AppDimensions.paddingMd           // EdgeInsets.all(16.0)
AppDimensions.paddingHorizontalMd // EdgeInsets.symmetric(horizontal: 16.0)
AppDimensions.paddingVerticalMd   // EdgeInsets.symmetric(vertical: 16.0)
```

### Rayons de bordure
```dart
AppDimensions.radiusSm    // 8.0
AppDimensions.radiusMd    // 12.0
AppDimensions.radiusLg    // 16.0
AppDimensions.radiusXl    // 20.0
```

### Responsive Design
```dart
// Vérification du type d'écran
AppDimensions.isMobile(context)
AppDimensions.isTablet(context)
AppDimensions.isDesktop(context)

// Padding adaptatif
AppDimensions.responsivePadding(context)

// Taille de police adaptative
AppDimensions.responsiveFontSize(context, baseFontSize)
```

## Styles prédéfinis

### Boutons
```dart
ElevatedButton(
  style: AppStyles.primaryButtonStyle,
  // ...
)

OutlinedButton(
  style: AppStyles.outlineButtonStyle,
  // ...
)
```

### Champs de saisie
```dart
TextField(
  decoration: AppStyles.inputDecoration(
    labelText: 'Label',
    hintText: 'Hint',
    prefixIcon: Icon(Icons.person),
  ),
)
```

### Cartes
```dart
Container(
  decoration: AppStyles.cardDecoration,
  // ...
)

// Carte personnalisée
Container(
  decoration: AppStyles.customCardDecoration(
    color: AppColors.primaryContainer,
  ),
  // ...
)
```

### Badges de statut
```dart
Container(
  decoration: AppStyles.statusBadgeDecoration('proposal'),
  // ...
)

// Container avec décoration de statut
Container(
  decoration: AppStyles.getStatusDecoration('work'),
  // ...
)
```

## Gradients

```dart
Container(
  decoration: BoxDecoration(
    gradient: AppStyles.primaryGradient,
  ),
  // ...
)
```

## Méthodes utilitaires

### Couleurs avec opacité
```dart
AppColors.withOpacity(AppColors.primary, 0.5)
```

### Couleurs de statut
```dart
Color proposalColor = AppColors.getProposalStatusColor('pending');
Color workColor = AppColors.getWorkStatusColor('in_progress');
Color announcementColor = AppColors.getAnnouncementStatusColor('active');
Color priorityColor = AppColors.getPriorityColor('high');
```

## Bonnes pratiques

1. **Utilisez toujours les constantes** au lieu de valeurs hardcodées
2. **Préférez les styles prédéfinis** pour la cohérence
3. **Utilisez le responsive design** pour s'adapter aux différentes tailles d'écran
4. **Respectez la hiérarchie des couleurs** Material Design 3
5. **Testez en mode clair et sombre** pour garantir la lisibilité

## Exemples complets

Consultez `theme_example.dart` pour voir des exemples d'utilisation complets de tous les éléments du système de thème.

## Personnalisation

Pour personnaliser le thème :
1. Modifiez les couleurs dans `app_colors.dart`
2. Ajustez les dimensions dans `app_dimensions.dart`
3. Adaptez les styles dans `app_styles.dart`
4. Régénérez le thème dans `app_theme.dart` si nécessaire

Le système est conçu pour être facilement extensible et maintenable.
