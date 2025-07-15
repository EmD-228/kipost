import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/buttons/kipost_button_v2.dart';
import 'package:kipost/theme/theme.dart';

/// Exemple d'utilisation du composant KipostButton
class KipostButtonExampleScreen extends StatefulWidget {
  const KipostButtonExampleScreen({super.key});

  @override
  State<KipostButtonExampleScreen> createState() => _KipostButtonExampleScreenState();
}

class _KipostButtonExampleScreenState extends State<KipostButtonExampleScreen> {
  bool _isLoading = false;

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemples de Boutons Kipost'),
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.responsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Types de boutons
            _buildSectionTitle('Types de boutons'),
            _buildButtonTypesSection(),
            
            SizedBox(height: AppDimensions.spacingXl),
            
            // Section Tailles
            _buildSectionTitle('Tailles de boutons'),
            _buildButtonSizesSection(),
            
            SizedBox(height: AppDimensions.spacingXl),
            
            // Section États
            _buildSectionTitle('États des boutons'),
            _buildButtonStatesSection(),
            
            SizedBox(height: AppDimensions.spacingXl),
            
            // Section Avec icônes
            _buildSectionTitle('Boutons avec icônes'),
            _buildButtonIconsSection(),
            
            SizedBox(height: AppDimensions.spacingXl),
            
            // Section Types avec paramètres
            _buildSectionTitle('Utilisation avec types explicites'),
            _buildFactoryMethodsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: AppDimensions.paddingVerticalMd,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppDimensions.fontSizeHeading,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildButtonTypesSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KipostButton(
                label: 'Primary',
                type: KipostButtonType.primary,
                onPressed: () => _showSnackbar('Primary button pressed'),
              ),
            ),
            SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: KipostButton(
                label: 'Secondary',
                type: KipostButtonType.secondary,
                onPressed: () => _showSnackbar('Secondary button pressed'),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMd),
        Row(
          children: [
            Expanded(
              child: KipostButton(
                label: 'Outline',
                type: KipostButtonType.outline,
                onPressed: () => _showSnackbar('Outline button pressed'),
              ),
            ),
            SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: KipostButton(
                label: 'Text',
                type: KipostButtonType.text,
                onPressed: () => _showSnackbar('Text button pressed'),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMd),
        KipostButton(
          label: 'Danger',
          type: KipostButtonType.danger,
          isFullWidth: true,
          onPressed: () => _showSnackbar('Danger button pressed'),
        ),
      ],
    );
  }

  Widget _buildButtonSizesSection() {
    return Column(
      children: [
        KipostButton(
          label: 'Small Button',
          size: KipostButtonSize.small,
          isFullWidth: true,
          onPressed: () => _showSnackbar('Small button pressed'),
        ),
        SizedBox(height: AppDimensions.spacingMd),
        KipostButton(
          label: 'Medium Button',
          size: KipostButtonSize.medium,
          isFullWidth: true,
          onPressed: () => _showSnackbar('Medium button pressed'),
        ),
        SizedBox(height: AppDimensions.spacingMd),
        KipostButton(
          label: 'Large Button',
          size: KipostButtonSize.large,
          isFullWidth: true,
          onPressed: () => _showSnackbar('Large button pressed'),
        ),
      ],
    );
  }

  Widget _buildButtonStatesSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KipostButton(
                label: 'Enabled',
                onPressed: () => _showSnackbar('Enabled button pressed'),
              ),
            ),
            SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: KipostButton(
                label: 'Disabled',
                onPressed: null, // Bouton désactivé
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMd),
        Row(
          children: [
            Expanded(
              child: KipostButton(
                label: _isLoading ? 'Loading...' : 'Toggle Loading',
                isLoading: _isLoading,
                onPressed: _toggleLoading,
              ),
            ),
            SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: KipostButton(
                label: 'Custom Color',
                customColor: Colors.purple,
                onPressed: () => _showSnackbar('Custom color button pressed'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtonIconsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: KipostButton(
                label: 'With Icon',
                icon: Iconsax.heart,
                onPressed: () => _showSnackbar('Icon button pressed'),
              ),
            ),
            SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: KipostButton(
                label: 'Suffix Icon',
                suffixIcon: Iconsax.arrow_right_2,
                type: KipostButtonType.outline,
                onPressed: () => _showSnackbar('Suffix icon button pressed'),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMd),
        KipostButton(
          label: 'Both Icons',
          icon: Iconsax.user,
          suffixIcon: Iconsax.arrow_right_2,
          isFullWidth: true,
          onPressed: () => _showSnackbar('Both icons button pressed'),
        ),
      ],
    );
  }

  Widget _buildFactoryMethodsSection() {
    return Column(
      children: [
        KipostButton(
          label: 'Primary Factory',
          type: KipostButtonType.primary,
          icon: Iconsax.flash_1,
          isFullWidth: true,
          onPressed: () => _showSnackbar('Primary factory method'),
        ),
        SizedBox(height: AppDimensions.spacingMd),
        KipostButton(
          label: 'Secondary Factory',
          type: KipostButtonType.secondary,
          icon: Iconsax.heart,
          isFullWidth: true,
          onPressed: () => _showSnackbar('Secondary factory method'),
        ),
        SizedBox(height: AppDimensions.spacingMd),
        Row(
          children: [
            Expanded(
              child: KipostButton(
                label: 'Outline',
                type: KipostButtonType.outline,
                icon: Iconsax.edit,
                onPressed: () => _showSnackbar('Outline factory method'),
              ),
            ),
            SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: KipostButton(
                label: 'Text',
                type: KipostButtonType.text,
                icon: Iconsax.info_circle,
                onPressed: () => _showSnackbar('Text factory method'),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMd),
        KipostButton(
          label: 'Danger Factory',
          type: KipostButtonType.danger,
          icon: Iconsax.trash,
          isFullWidth: true,
          onPressed: () => _showSnackbar('Danger factory method'),
        ),
      ],
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
