import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/components/kipost_textfield.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/controllers/annoncement_controller.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  final List<String> _categories = [
    'Menuiserie',
    'Plomberie',
    'Électricité',
    'Aide ménagère',
    'Transport',
    'Autre',
  ];

  final AnnouncementController _announcementController = Get.put(AnnouncementController());

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await _announcementController.createAnnouncement(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      location: _locationController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle annonce'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              KipostTextField(
                controller: _titleController,
                label: 'Titre',
                icon: Iconsax.edit,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: const Icon(Iconsax.category),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (val) => val == null ? 'Choisis une catégorie' : null,
              ),
              const SizedBox(height: 12),
              KipostTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Iconsax.textalign_left,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 12),
              KipostTextField(
                controller: _locationController,
                label: 'Localisation (ville/quartier)',
                icon: Iconsax.location,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24),
              Obx(() => KipostButton(
                    label: 'Publier l\'annonce',
                    icon: Iconsax.send_2,
                    loading: _announcementController.loading.value,
                    onPressed: _submit,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}