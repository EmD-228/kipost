import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/controllers/annoncement_controller.dart';
import 'package:kipost/components/announcement_creation/index.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> 
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  late AnimationController _animationController;
  late AnimationController _stepAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedCategory;
  String? _selectedUrgency;
  int _currentStep = 0;
  bool _showPreview = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Menuiserie', 'icon': Iconsax.bezier, 'color': Colors.amber, 'gradient': [Colors.amber, Colors.orange]},
    {'name': 'Plomberie', 'icon': Iconsax.setting_4, 'color': Colors.blue, 'gradient': [Colors.blue, Colors.indigo]},
    {'name': 'Électricité', 'icon': Iconsax.flash_1, 'color': Colors.yellow, 'gradient': [Colors.yellow.shade600, Colors.orange]},
    {'name': 'Aide ménagère', 'icon': Iconsax.brush_2, 'color': Colors.green, 'gradient': [Colors.green, Colors.teal]},
    {'name': 'Transport', 'icon': Iconsax.car, 'color': Colors.purple, 'gradient': [Colors.purple, Colors.deepPurple]},
    {'name': 'Jardinage', 'icon': Iconsax.tree, 'color': Colors.teal, 'gradient': [Colors.teal, Colors.green]},
    {'name': 'Informatique', 'icon': Iconsax.monitor, 'color': Colors.indigo, 'gradient': [Colors.indigo, Colors.blue]},
    {'name': 'Autre', 'icon': Iconsax.more, 'color': Colors.grey, 'gradient': [Colors.grey.shade600, Colors.grey.shade400]},
  ];

  final List<Map<String, dynamic>> _urgencyLevels = [
    {'name': 'Pas urgent', 'desc': '1-2 semaines', 'color': Colors.green, 'icon': Iconsax.clock},
    {'name': 'Modéré', 'desc': '3-7 jours', 'color': Colors.orange, 'icon': Iconsax.timer_1},
    {'name': 'Urgent', 'desc': '24-48h', 'color': Colors.red, 'icon': Iconsax.danger},
  ];

  final AnnouncementController _announcementController = Get.put(AnnouncementController());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    // Add listeners to text controllers to update UI in real-time
    _titleController.addListener(_updateStepValidation);
    _descriptionController.addListener(_updateStepValidation);
    _locationController.addListener(_updateStepValidation);
    
    _animationController.forward();
  }

  // Method to force UI update when text fields change
  void _updateStepValidation() {
    setState(() {
      // This will trigger a rebuild and update the button states
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stepAnimationController.dispose();
    _pageController.dispose();
    
    // Remove listeners before disposing controllers
    _titleController.removeListener(_updateStepValidation);
    _descriptionController.removeListener(_updateStepValidation);
    _locationController.removeListener(_updateStepValidation);
    
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate form and required selections

    
    // Ensure all required fields are selected
    if (_selectedCategory == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner une catégorie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    if (_selectedUrgency == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner un niveau d\'urgence',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    await _announcementController.createAnnouncement(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      location: _locationController.text.trim(),
    );
  }

  void _nextStep() {
    // Validate current step before proceeding
    if (!_canProceedFromStep(_currentStep)) {
      return;
    }
    
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _stepAnimationController.reset();
      _stepAnimationController.forward();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Before showing preview, ensure all steps are completed
      if (_selectedCategory != null && 
          _titleController.text.trim().isNotEmpty &&
          _descriptionController.text.trim().isNotEmpty &&
          _locationController.text.trim().isNotEmpty &&
          _selectedUrgency != null) {
        setState(() => _showPreview = true);
      }
    }
  }

  void _previousStep() {
    if (_showPreview) {
      setState(() => _showPreview = false);
    } else if (_currentStep > 0) {
      setState(() => _currentStep--);
      _stepAnimationController.reset();
      _stepAnimationController.forward();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  bool _canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return _selectedCategory != null;
      case 1:
        // Check if required fields are not empty and trimmed
        final title = _titleController.text.trim();
        final description = _descriptionController.text.trim();
        final location = _locationController.text.trim();
        
        return title.isNotEmpty && 
               description.isNotEmpty &&
               location.isNotEmpty;
      case 2:
        return _selectedUrgency != null;
      default:
        return false;
    }
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Choisissez une catégorie';
      case 1:
        return 'Détails de l\'annonce';
      case 2:
        return 'Niveau d\'urgence';
      default:
        return '';
    }
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Sélectionnez la catégorie qui correspond le mieux à votre besoin';
      case 1:
        return 'Décrivez précisément votre demande pour attirer les bons prestataires';
      case 2:
        return 'Indiquez dans quels délais vous souhaitez une réponse';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Iconsax.arrow_left,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Nouvelle annonce',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _showPreview ? _buildPreviewStep() : _buildStepperContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepperContent() {
    return Column(
      children: [
        // Progress indicator moderne
        StepProgressIndicator(
          currentStep: _currentStep,
          stepTitle: _getStepTitle(_currentStep),
          stepDescription: _getStepDescription(_currentStep),
        ),
        
        // Contenu des étapes
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentStep = index),
            children: [
              CategorySelectionStep(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                },
                animationController: _stepAnimationController,
              ),
              AnnouncementDetailsStep(
                formKey: _formKey,
                titleController: _titleController,
                descriptionController: _descriptionController,
                locationController: _locationController,
                budgetController: _budgetController,
              ),
              UrgencySelectionStep(
                urgencyLevels: _urgencyLevels,
                selectedUrgency: _selectedUrgency,
                onUrgencySelected: (urgency) {
                  setState(() => _selectedUrgency = urgency);
                },
                animationController: _stepAnimationController,
              ),
            ],
          ),
        ),
        
        // Boutons de navigation
        StepNavigationButtons(
          currentStep: _currentStep,
          canProceed: _canProceedFromStep(_currentStep),
          onPrevious: _currentStep > 0 ? _previousStep : null,
          onNext: _canProceedFromStep(_currentStep) ? _nextStep : null,
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    return AnnouncementPreviewStep(
      selectedCategory: _selectedCategory ?? '',
      selectedUrgency: _selectedUrgency ?? '',
      title: _titleController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      budget: _budgetController.text,
      urgencyLevels: _urgencyLevels,
      onEdit: () => setState(() => _showPreview = false),
      onSubmit: _submit,
      announcementController: _announcementController,
    );
  }
}