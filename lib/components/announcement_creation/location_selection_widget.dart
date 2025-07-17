import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/controllers/app_controller.dart';
import 'package:kipost/theme/app_colors.dart';
import 'package:kipost/components/announcement_creation/custom_text_field.dart';
import 'package:kipost/services/location_service.dart';
import 'package:kipost/utils/snackbar_helper.dart';

enum LocationMode { current, manual }

class LocationSelectionWidget extends StatefulWidget {
  final TextEditingController locationController;
  final Function(Map<String, dynamic>) onLocationChanged;
  final Color primaryColor;

  const LocationSelectionWidget({
    super.key,
    required this.locationController,
    required this.onLocationChanged,
    required this.primaryColor,
  });

  @override
  State<LocationSelectionWidget> createState() => _LocationSelectionWidgetState();
}

class _LocationSelectionWidgetState extends State<LocationSelectionWidget> {
  final AppController _appController = Get.find<AppController>();
  LocationMode _selectedMode = LocationMode.current;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // Si l'utilisateur a déjà une position, on l'utilise par défaut
    if (_appController.location.isNotEmpty) {
      _updateLocationFromApp();
    } else {
      _selectedMode = LocationMode.manual;
    }
  }

  void _updateLocationFromApp() {
    if (_appController.location.isNotEmpty) {
      final location = Map<String, dynamic>.from(_appController.location);
      final displayText = LocationService.formatAddressForDisplay(location);
      widget.locationController.text = displayText;
      widget.onLocationChanged(location);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      // Utiliser le service de localisation
      final locationData = await LocationService.getCurrentLocationWithAddress();
      
      // Mettre à jour l'interface
      final displayText = LocationService.formatAddressForDisplay(locationData);
      widget.locationController.text = displayText;
      widget.onLocationChanged(locationData);
    } catch (e) {
      // En cas d'erreur, on bascule en mode manuel
      setState(() => _selectedMode = LocationMode.manual);
      
      if (mounted) {
        SnackbarHelper.showError(
          title: 'Erreur de localisation',
          message: e.toString(),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _onManualLocationChanged(String value) {
    final location = {
      'city': value.trim(),
      'country': 'Côte d\'Ivoire',
      'latitude': 0.0,
      'longitude': 0.0,
    };
    widget.onLocationChanged(location);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mode selection
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedMode = LocationMode.current);
                    if (_appController.location.isNotEmpty) {
                      _updateLocationFromApp();
                    } else {
                      _getCurrentLocation();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedMode == LocationMode.current 
                          ? widget.primaryColor 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.gps,
                          size: 16,
                          color: _selectedMode == LocationMode.current 
                              ? AppColors.onPrimary 
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Position actuelle',
                          style: TextStyle(
                            color: _selectedMode == LocationMode.current 
                                ? AppColors.onPrimary 
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedMode = LocationMode.manual);
                    widget.locationController.clear();
                    widget.onLocationChanged({});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedMode == LocationMode.manual 
                          ? widget.primaryColor 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.edit,
                          size: 16,
                          color: _selectedMode == LocationMode.manual 
                              ? AppColors.onPrimary 
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saisir manuellement',
                          style: TextStyle(
                            color: _selectedMode == LocationMode.manual 
                                ? AppColors.onPrimary 
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Location input based on selected mode
        if (_selectedMode == LocationMode.current) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.location,
                    color: widget.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Position actuelle',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.locationController.text.isNotEmpty 
                            ? widget.locationController.text 
                            : 'Chargement...',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoadingLocation)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
                    ),
                  )
                else
                  IconButton(
                    onPressed: _getCurrentLocation,
                    icon: Icon(
                      Iconsax.refresh,
                      color: widget.primaryColor,
                      size: 20,
                    ),
                    tooltip: 'Actualiser la position',
                  ),
              ],
            ),
          ),
        ] else ...[
          CustomTextField(
            controller: widget.locationController,
            label: 'Localisation',
            hint: 'Ex: Cocody, Abidjan',
            icon: Iconsax.location,
            primaryColor: widget.primaryColor,
            onChanged: _onManualLocationChanged,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La localisation est requise';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
