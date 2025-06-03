import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/controllers/annoncement_controller.dart';

class PreviewHeader extends StatelessWidget {
  const PreviewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Iconsax.eye,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aperçu de votre annonce',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vérifiez les informations avant publication',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewInfoChip extends StatelessWidget {
  final String text;
  final Color color;

  const PreviewInfoChip({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class AnnouncementPreviewStep extends StatelessWidget {
  final String selectedCategory;
  final String selectedUrgency;
  final String title;
  final String description;
  final String location;
  final String budget;
  final List<Map<String, dynamic>> urgencyLevels;
  final VoidCallback onEdit;
  final VoidCallback onSubmit;
  final AnnouncementController announcementController;

  const AnnouncementPreviewStep({
    super.key,
    required this.selectedCategory,
    required this.selectedUrgency,
    required this.title,
    required this.description,
    required this.location,
    required this.budget,
    required this.urgencyLevels,
    required this.onEdit,
    required this.onSubmit,
    required this.announcementController,
  });

  Color? _getUrgencyColor() {
    final urgency = urgencyLevels.firstWhereOrNull((u) => u['name'] == selectedUrgency);
    return urgency?['color'];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // En-tête de prévisualisation
          const PreviewHeader(),
          
          const SizedBox(height: 24),
          
          // Carte de prévisualisation
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catégorie et urgence
                  Row(
                    children: [
                      PreviewInfoChip(
                        text: selectedCategory,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      PreviewInfoChip(
                        text: selectedUrgency,
                        color: _getUrgencyColor() ?? Colors.grey,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Titre
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Localisation
                  Row(
                    children: [
                      const Icon(
                        Iconsax.location,
                        color: Colors.deepPurple,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        location,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  
                  if (budget.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Iconsax.money,
                          color: Colors.deepPurple,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${budget}€',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Boutons de prévisualisation
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Modifier',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Obx(() => KipostButton(
                        label: announcementController.loading.value ? 'Publication...' : 'Publier',
                        icon: Iconsax.send_2,
                        onPressed: announcementController.loading.value ? null : onSubmit,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
