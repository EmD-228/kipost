# KipostButton - Composant de Bouton

Un composant de bouton personnalisé et polyvalent pour l'application Kipost, utilisant le système de thème unifié.

## Fonctionnalités

- **5 types de boutons** : Primary, Secondary, Outline, Text, Danger
- **3 tailles** : Small, Medium, Large
- **États gérés** : Normal, Disabled, Loading
- **Support des icônes** : Icône de début et/ou de fin
- **Personnalisation** : Couleurs, padding, border radius personnalisables
- **Responsive** : S'adapte aux différentes tailles d'écran
- **Méthodes factory** : Utilisation simplifiée

## Types de boutons

### Primary (par défaut)
Bouton principal avec gradient et ombre, utilisé pour les actions principales.

### Secondary
Bouton secondaire avec couleur unie, pour les actions secondaires importantes.

### Outline
Bouton avec bordure uniquement, pour les actions alternatives.

### Text
Bouton sans arrière-plan, pour les actions subtiles.

### Danger
Bouton rouge pour les actions destructives (supprimer, annuler, etc.).

## Tailles

- **Small** : 36px de hauteur
- **Medium** : 48px de hauteur (par défaut)
- **Large** : 56px de hauteur

## Utilisation

### Utilisation de base

```dart
KipostButton(
  label: 'Mon Bouton',
  onPressed: () => print('Bouton pressé'),
)
```

### Avec type et taille

```dart
KipostButton(
  label: 'Valider',
  type: KipostButtonType.primary,
  size: KipostButtonSize.large,
  isFullWidth: true,
  onPressed: () => _valider(),
)
```

### Avec icônes

```dart
KipostButton(
  label: 'Se connecter',
  icon: Iconsax.login,
  suffixIcon: Iconsax.arrow_right_2,
  onPressed: () => _login(),
)
```

### État de chargement

```dart
KipostButton(
  label: _isLoading ? 'Connexion...' : 'Se connecter',
  isLoading: _isLoading,
  onPressed: _isLoading ? null : _login,
)
```

### Bouton désactivé

```dart
KipostButton(
  label: 'Indisponible',
  onPressed: null, // null = désactivé
)
```

### Personnalisation

```dart
KipostButton(
  label: 'Personnalisé',
  customColor: Colors.purple,
  customTextColor: Colors.white,
  customPadding: EdgeInsets.all(20),
  customBorderRadius: BorderRadius.circular(30),
  onPressed: () => _custom(),
)
```

## Méthodes Factory (Recommandées)

### Primary
```dart
KipostButton.primary(
  label: 'Action Principale',
  icon: Iconsax.flash_1,
  onPressed: () => _actionPrincipale(),
)
```

### Secondary
```dart
KipostButton.secondary(
  label: 'Action Secondaire',
  onPressed: () => _actionSecondaire(),
)
```

### Outline
```dart
KipostButton.outline(
  label: 'Modifier',
  icon: Iconsax.edit,
  onPressed: () => _modifier(),
)
```

### Text
```dart
KipostButton.text(
  label: 'Annuler',
  onPressed: () => _annuler(),
)
```

### Danger
```dart
KipostButton.danger(
  label: 'Supprimer',
  icon: Iconsax.trash,
  onPressed: () => _supprimer(),
)
```

## Paramètres

| Paramètre | Type | Défaut | Description |
|-----------|------|--------|-------------|
| `label` | String | - | **Requis.** Texte du bouton |
| `onPressed` | VoidCallback? | null | Fonction appelée lors du clic |
| `icon` | IconData? | null | Icône au début du bouton |
| `suffixIcon` | IconData? | null | Icône à la fin du bouton |
| `type` | KipostButtonType | primary | Type de bouton |
| `size` | KipostButtonSize | medium | Taille du bouton |
| `isLoading` | bool | false | Affiche un indicateur de chargement |
| `isFullWidth` | bool | false | Prend toute la largeur disponible |
| `customColor` | Color? | null | Couleur personnalisée |
| `customTextColor` | Color? | null | Couleur du texte personnalisée |
| `customPadding` | EdgeInsetsGeometry? | null | Padding personnalisé |
| `customBorderRadius` | BorderRadius? | null | Border radius personnalisé |

## Exemples complets

### Formulaire de connexion
```dart
Column(
  children: [
    KipostButton.primary(
      label: 'Se connecter',
      icon: Iconsax.login,
      isFullWidth: true,
      isLoading: _isLoading,
      onPressed: _isLoading ? null : _login,
    ),
    SizedBox(height: 16),
    KipostButton.text(
      label: 'Mot de passe oublié ?',
      onPressed: () => _forgotPassword(),
    ),
  ],
)
```

### Actions de carte
```dart
Row(
  children: [
    Expanded(
      child: KipostButton.outline(
        label: 'Modifier',
        icon: Iconsax.edit,
        size: KipostButtonSize.small,
        onPressed: () => _edit(),
      ),
    ),
    SizedBox(width: 8),
    Expanded(
      child: KipostButton.danger(
        label: 'Supprimer',
        icon: Iconsax.trash,
        size: KipostButtonSize.small,
        onPressed: () => _delete(),
      ),
    ),
  ],
)
```

### Bouton de navigation
```dart
KipostButton.primary(
  label: 'Continuer',
  suffixIcon: Iconsax.arrow_right_2,
  size: KipostButtonSize.large,
  isFullWidth: true,
  onPressed: () => _next(),
)
```

## Intégration avec le thème

Le composant utilise automatiquement les couleurs et dimensions du système de thème Kipost :
- Couleurs : `AppColors.*`
- Dimensions : `AppDimensions.*`
- Styles : Cohérents avec le design system

## Accessibilité

- Support des états disabled/enabled
- Indicateurs de chargement appropriés
- Tailles de boutons respectant les guidelines
- Couleurs avec contraste suffisant

Consultez `kipost_button_example.dart` pour voir tous les exemples d'utilisation.
