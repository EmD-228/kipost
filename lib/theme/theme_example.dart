import 'package:flutter/material.dart';
import 'package:kipost/theme/theme.dart';

/// Exemple d'utilisation du système de thème Kipost
/// Ce fichier montre comment utiliser les différents éléments du thème
class ThemeExampleScreen extends StatelessWidget {
  const ThemeExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple de Thème Kipost'),
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.responsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Couleurs
            _buildSectionTitle('Couleurs'),
            _buildColorsSection(),
            
            SizedBox(height: AppDimensions.spacingXl),
            
            // Section Boutons
            _buildSectionTitle('Boutons'),
            _buildButtonsSection(),
            
            SizedBox(height: AppDimensions.spacingXl),
            
            // Section Cartes
            _buildSectionTitle('Cartes'),
            _buildCardsSection(),
            
            SizedBox(height: AppDimensions.spacingXl),
            
            // Section Champs de saisie
            _buildSectionTitle('Champs de saisie'),
            _buildInputsSection(),
            
            SizedBox(height: AppDimensions.spacingXl),
            
            // Section Statuts
            _buildSectionTitle('Badges de statut'),
            _buildStatusSection(),
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

  Widget _buildColorsSection() {
    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      children: [
        _buildColorChip('Primary', AppColors.primary),
        _buildColorChip('Secondary', AppColors.secondary),
        _buildColorChip('Success', AppColors.success),
        _buildColorChip('Warning', AppColors.warning),
        _buildColorChip('Error', AppColors.error),
        _buildColorChip('Info', AppColors.info),
      ],
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Container(
      padding: AppDimensions.paddingSm,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppDimensions.borderRadiusSm,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _getContrastColor(color),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildButtonsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: AppStyles.primaryButtonStyle,
                onPressed: () {},
                child: const Text('Primary'),
              ),
            ),
            SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: ElevatedButton(
                style: AppStyles.secondaryButtonStyle,
                onPressed: () {},
                child: const Text('Secondary'),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.spacingMd),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: AppStyles.outlineButtonStyle,
                onPressed: () {},
                child: const Text('Outline'),
              ),
            ),
            SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: TextButton(
                style: AppStyles.textButtonStyle,
                onPressed: () {},
                child: const Text('Text'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: AppDimensions.cardPadding,
          decoration: AppStyles.cardDecoration,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carte Standard',
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppDimensions.spacingSm),
              Text('Contenu de la carte avec un style standard.'),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spacingMd),
        Container(
          width: double.infinity,
          padding: AppDimensions.cardPadding,
          decoration: AppStyles.customCardDecoration(
            color: AppColors.primaryContainer,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carte Personnalisée',
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
              SizedBox(height: AppDimensions.spacingSm),
              Text(
                'Carte avec couleur personnalisée.',
                style: TextStyle(color: AppColors.onPrimaryContainer),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputsSection() {
    return Column(
      children: [
        TextField(
          decoration: AppStyles.inputDecoration(
            labelText: 'Nom',
            hintText: 'Entrez votre nom',
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        SizedBox(height: AppDimensions.spacingMd),
        TextField(
          decoration: AppStyles.inputDecoration(
            labelText: 'Email',
            hintText: 'votre.email@example.com',
            prefixIcon: const Icon(Icons.email),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      children: [
        _buildStatusBadge('proposal', 'Proposition'),
        _buildStatusBadge('work', 'Travail'),
        _buildStatusBadge('announcement', 'Annonce'),
        _buildStatusBadge('completed', 'Terminé'),
        _buildStatusBadge('pending', 'En attente'),
        _buildStatusBadge('cancelled', 'Annulé'),
      ],
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: AppStyles.statusBadgeDecoration(status),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: AppDimensions.fontSizeSm,
        ),
      ),
    );
  }
}
