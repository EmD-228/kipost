import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/kipost_textfield.dart';

class FormFieldContainer extends StatelessWidget {
  final Widget child;

  const FormFieldContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AnnouncementDetailsStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final TextEditingController budgetController;

  const AnnouncementDetailsStep({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    required this.budgetController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Titre
            FormFieldContainer(
              child: KipostTextField(
                controller: titleController,
                label: 'Titre de votre annonce',
                icon: Iconsax.edit,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un titre';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Description
            FormFieldContainer(
              child: KipostTextField(
                controller: descriptionController,
                label: 'Description détaillée',
                icon: Iconsax.document_text,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez décrire votre besoin';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Localisation
            FormFieldContainer(
              child: KipostTextField(
                controller: locationController,
                label: 'Localisation (ville/quartier)',
                icon: Iconsax.location,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez indiquer la localisation';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Budget (optionnel)
            FormFieldContainer(
              child: KipostTextField(
                controller: budgetController,
                label: 'Budget estimé (optionnel)',
                icon: Iconsax.money,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
