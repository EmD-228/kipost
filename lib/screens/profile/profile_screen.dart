import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/components/kipost_textfield.dart';
import 'package:kipost/controllers/auth_controller.dart';
import 'package:kipost/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();
  
  bool _isLoading = false;
  bool _isEditing = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authController.getCurrentUserProfile();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name;
          _phoneController.text = user.phone ?? '';
          _locationController.text = user.location ?? '';
        });
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors du chargement du profil',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Vérifier qu'au moins un rôle est sélectionné
    if (_currentUser != null && !_currentUser!.isClient && !_currentUser!.isProvider) {
      Get.snackbar(
        'Erreur',
        'Vous devez sélectionner au moins un rôle',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        );
        
        await _authController.updateUserProfile(updatedUser);
        
        setState(() {
          _currentUser = updatedUser;
          _isEditing = false;
        });
        
        Get.snackbar(
          'Succès',
          'Profil mis à jour avec succès',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la mise à jour : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Mon Profil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Iconsax.edit, color: Colors.deepPurple),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.user,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          if (_currentUser != null) ...[
                            Text(
                              _currentUser!.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentUser!.email,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_currentUser!.isClient) 
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Client',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                if (_currentUser!.isProvider)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Prestataire',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Profile Form
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations personnelles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          KipostTextField(
                            controller: _nameController,
                            label: 'Nom complet',
                            icon: Iconsax.user,
                            readOnly: !_isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez saisir votre nom';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          KipostTextField(
                            controller: _phoneController,
                            label: 'Téléphone (optionnel)',
                            icon: Iconsax.call,
                            readOnly: !_isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          KipostTextField(
                            controller: _locationController,
                            label: 'Localisation (optionnel)',
                            icon: Iconsax.location,
                            readOnly: !_isEditing,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Role management section (only in edit mode)
                          if (_isEditing) ...[
                            Text(
                              'Mes rôles',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    title: const Text('Client'),
                                    subtitle: const Text('Poster des annonces'),
                                    value: _currentUser?.isClient ?? false,
                                    onChanged: (value) {
                                      if (_currentUser != null) {
                                        setState(() {
                                          _currentUser = _currentUser!.copyWith(
                                            isClient: value ?? false,
                                          );
                                        });
                                      }
                                    },
                                    activeColor: Colors.deepPurple,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  CheckboxListTile(
                                    title: const Text('Prestataire'),
                                    subtitle: const Text('Répondre aux annonces'),
                                    value: _currentUser?.isProvider ?? false,
                                    onChanged: (value) {
                                      if (_currentUser != null) {
                                        setState(() {
                                          _currentUser = _currentUser!.copyWith(
                                            isProvider: value ?? false,
                                          );
                                        });
                                      }
                                    },
                                    activeColor: Colors.deepPurple,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          if (_isEditing) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() => _isEditing = false);
                                      _loadUserProfile(); // Reset form
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      side: BorderSide(color: Colors.grey.shade400),
                                    ),
                                    child: const Text('Annuler'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: KipostButton(
                                    label: 'Sauvegarder',
                                    onPressed: _updateProfile,
                                    icon: Iconsax.tick_circle,
                                    loading: _isLoading,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Logout Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton.icon(
                        onPressed: () async {
                          await _authController.logout();
                        },
                        icon: const Icon(Iconsax.logout, color: Colors.red),
                        label: const Text(
                          'Se déconnecter',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
