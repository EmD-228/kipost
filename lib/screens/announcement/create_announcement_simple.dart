import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/controllers/annoncement_controller.dart';
import 'package:kipost/models/category.dart';
import 'package:kipost/models/urgency_level.dart';

class CreateAnnouncementSimpleScreen extends StatefulWidget {
  const CreateAnnouncementSimpleScreen({super.key});

  @override
  State<CreateAnnouncementSimpleScreen> createState() => _CreateAnnouncementSimpleScreenState();
}

class _CreateAnnouncementSimpleScreenState extends State<CreateAnnouncementSimpleScreen> {
  final AnnouncementController _announcementController = Get.put(AnnouncementController());
  final List<Category> _categories = Category.getDefaultCategories();
  final List<UrgencyLevel> _urgencyLevels = UrgencyLevel.getDefaultUrgencyLevels();

  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  String? _selectedUrgency;
  final _titleController = TextEditingController();

  // Helper method to get color based on urgency level
  Color _getUrgencyColor(UrgencyLevel urgency) {
    if (urgency.isUrgent) return Colors.red;
    if (urgency.isModerate) return Colors.orange;
    return Colors.green;
  }

  // Helper method to get icon based on urgency level
  IconData _getUrgencyIcon(UrgencyLevel urgency) {
    if (urgency.isUrgent) return Iconsax.danger;
    if (urgency.isModerate) return Iconsax.timer_1;
    return Iconsax.clock;
  }

  // Helper method to get color based on category
  Color _getCategoryColor(Category category) {
    switch (category.id) {
      case 'menuiserie':
        return Colors.brown;
      case 'plomberie':
        return Colors.blue;
      case 'electricite':
        return Colors.orange;
      case 'aide_menagere':
        return Colors.pink;
      case 'transport':
        return Colors.green;
      case 'jardinage':
        return Colors.lightGreen;
      case 'informatique':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null || _selectedUrgency == null) {
      if (_selectedCategory == null) {
        Get.snackbar(
          'Erreur',
          'Veuillez sélectionner une catégorie',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
      if (_selectedUrgency == null) {
        Get.snackbar(
          'Erreur',
          'Veuillez sélectionner un niveau d\'urgence',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Parse le prix s'il est fourni
      double? parsedPrice;
      if (_priceController.text.trim().isNotEmpty) {
        parsedPrice = double.tryParse(_priceController.text.trim());
      }
      
      await _announcementController.createAnnouncement(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategory!, // ID de la catégorie
        urgencyLevelId: _selectedUrgency!, // ID du niveau d'urgence
        location: _locationController.text.trim(),
        price: parsedPrice,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      children: [
        if (_selectedCategory != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _categories.firstWhere((cat) => cat.id == _selectedCategory).icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _categories.firstWhere((cat) => cat.id == _selectedCategory).name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Catégorie sélectionnée',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _selectedCategory = null),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category.id;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category.id),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? _getCategoryColor(category).withOpacity(0.1) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _getCategoryColor(category) : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? _getCategoryColor(category) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        category.icon,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? _getCategoryColor(category) : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildUrgencySelection() {
    return Column(
      children: [
        if (_selectedUrgency != null)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getUrgencyIcon(_urgencyLevels.firstWhere((urg) => urg.id == _selectedUrgency)),
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _urgencyLevels.firstWhere((urg) => urg.id == _selectedUrgency).name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Niveau d\'urgence sélectionné',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _selectedUrgency = null),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _urgencyLevels.length,
          itemBuilder: (context, index) {
            final urgency = _urgencyLevels[index];
            final isSelected = _selectedUrgency == urgency.id;
            final urgencyColor = _getUrgencyColor(urgency);
            final urgencyIcon = _getUrgencyIcon(urgency);
            
            return GestureDetector(
              onTap: () => setState(() => _selectedUrgency = urgency.id),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? urgencyColor.withOpacity(0.1) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? urgencyColor : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? urgencyColor : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        urgencyIcon,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        urgency.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? urgencyColor : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(16),
        labelStyle: TextStyle(color: Colors.grey.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Iconsax.arrow_left, size: 20, color: Colors.grey),
          ),
        ),
        title: const Text(
          'Créer une annonce',
          style: TextStyle(
            color: Colors.black87,
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.document_text,
                        size: 32,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Décrivez votre besoin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Remplissez les informations ci-dessous pour publier votre annonce',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Catégorie Section
              _buildSection(
                title: 'Catégorie',
                icon: Iconsax.category,
                child: _buildCategorySelection(),
              ),
              
              const SizedBox(height: 20),
              
              // Urgence Section
              _buildSection(
                title: 'Niveau d\'urgence',
                icon: Iconsax.clock,
                child: _buildUrgencySelection(),
              ),
              
              const SizedBox(height: 20),
              
              // Informations Section
              _buildSection(
                title: 'Informations',
                icon: Iconsax.edit,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Titre de l\'annonce',
                      hint: 'Ex: Réparation de plomberie urgente',
                      icon: Iconsax.text,
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
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description détaillée',
                      hint: 'Décrivez précisément votre besoin...',
                      icon: Iconsax.document_text,
                      maxLines: 4,
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
                    _buildTextField(
                      controller: _locationController,
                      label: 'Localisation',
                      hint: 'Ex: Cocody, Abidjan',
                      icon: Iconsax.location,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La localisation est requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _priceController,
                      label: 'Budget estimé (optionnel)',
                      hint: 'Ex: 50000 FCFA',
                      icon: Iconsax.money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final price = int.tryParse(value.trim());
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
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.send_1, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Publier l\'annonce',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
