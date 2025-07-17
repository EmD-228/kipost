import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/services/announcement_service.dart';
import 'package:kipost/models/category.dart';
import 'package:kipost/models/urgency_level.dart';
import 'package:kipost/components/announcement_creation/announcement_widgets.dart';
import 'package:kipost/controllers/app_controller.dart';
import 'package:kipost/utils/snackbar_helper.dart';
import 'package:kipost/theme/app_colors.dart';

class CreateAnnouncementSimpleScreen extends StatefulWidget {
  const CreateAnnouncementSimpleScreen({super.key});

  @override
  State<CreateAnnouncementSimpleScreen> createState() => _CreateAnnouncementSimpleScreenState();
}

class _CreateAnnouncementSimpleScreenState extends State<CreateAnnouncementSimpleScreen> {
  // Services
  final AnnouncementService _announcementService = AnnouncementService();
  final AppController _appController = Get.find<AppController>();
  
  // Données
  final List<Category> _categories = Category.getDefaultCategories();
  final List<UrgencyLevel> _urgencyLevels = UrgencyLevel.getDefaultUrgencyLevels();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // État
  bool _isLoading = false;
  String? _selectedCategory;
  String? _selectedUrgency;
  Map<String, dynamic> _selectedLocation = {};
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      SnackbarHelper.showError(
        title: 'Erreur',
        message: 'Veuillez sélectionner une catégorie',
      );
      return;
    }

    if (_selectedUrgency == null) {
      SnackbarHelper.showError(
        title: 'Erreur',
        message: 'Veuillez sélectionner un niveau d\'urgence',
      );
      return;
    }

    // Vérifier que la localisation est définie
    if (_selectedLocation.isEmpty && _locationController.text.trim().isEmpty) {
      SnackbarHelper.showError(
        title: 'Erreur',
        message: 'Veuillez définir une localisation',
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Parse le prix s'il est fourni
      double? parsedPrice;
      if (_priceController.text.trim().isNotEmpty) {
        parsedPrice = double.tryParse(_priceController.text.trim());
      }

      // Préparer la localisation
      Map<String, dynamic> location = {};
      if (_selectedLocation.isNotEmpty) {
        location = _selectedLocation;
      } else if (_appController.location.isNotEmpty) {
        location = Map<String, dynamic>.from(_appController.location);
      } else {
        location = {
          'city': _locationController.text.trim(),
          'country': 'Côte d\'Ivoire',
          'latitude': 0.0,
          'longitude': 0.0,
        };
      }
      
      await _announcementService.createAnnouncement(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        location: location,
        budget: parsedPrice,
        urgency: _selectedUrgency!,
      );
      Get.back();

      SnackbarHelper.showSuccess(
        title: 'Succès',
        message: 'Annonce créée avec succès',
      );

    } catch (e) {
      SnackbarHelper.showError(
        title: 'Erreur',
        message: 'Erreur lors de la création: ${e.toString()}',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Iconsax.arrow_left, 
              size: 20, 
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          'Créer une annonce',
          style: TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AnnouncementHeaderWidget(
                title: 'Décrivez votre besoin',
                subtitle: 'Remplissez les informations ci-dessous pour publier votre annonce',
                icon: Iconsax.document_text,
                primaryColor: AppColors.primary,
              ),
              
              const SizedBox(height: 24),
              
              // Catégorie Section
              SectionWidget(
                title: 'Catégorie',
                icon: Iconsax.category,
                iconColor: AppColors.primary,
                child: CategorySelectionWidget(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Urgence Section
              SectionWidget(
                title: 'Niveau d\'urgence',
                icon: Iconsax.clock,
                iconColor: AppColors.primary,
                child: UrgencySelectionWidget(
                  urgencyLevels: _urgencyLevels,
                  selectedUrgency: _selectedUrgency,
                  onUrgencySelected: (urgency) {
                    setState(() => _selectedUrgency = urgency);
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Informations Section
              SectionWidget(
                title: 'Informations',
                icon: Iconsax.edit,
                iconColor: AppColors.primary,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      label: 'Titre de l\'annonce',
                      hint: 'Ex: Réparation de plomberie urgente',
                      icon: Iconsax.text,
                      primaryColor: AppColors.primary,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le titre est requis';
                        }
                        if (value.trim().length < 10) {
                          return 'Le titre doit contenir au moins 10 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description détaillée',
                      hint: 'Décrivez précisément votre besoin...',
                      icon: Iconsax.document_text,
                      maxLines: 4,
                      primaryColor: AppColors.primary,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La description est requise';
                        }
                        if (value.trim().length < 20) {
                          return 'La description doit contenir au moins 20 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    LocationSelectionWidget(
                      locationController: _locationController,
                      primaryColor: AppColors.secondary,
                      onLocationChanged: (location) {
                        setState(() => _selectedLocation = location);
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _priceController,
                      label: 'Budget estimé (optionnel)',
                      hint: 'Ex: 50000 FCFA',
                      icon: Iconsax.money,
                      keyboardType: TextInputType.number,
                      primaryColor: AppColors.primary,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final price = double.tryParse(value.trim());
                          if (price == null || price <= 0) {
                            return 'Veuillez entrer un montant valide';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                          ),
                        )
                      : Text(
                        'Publier l\'annonce',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
