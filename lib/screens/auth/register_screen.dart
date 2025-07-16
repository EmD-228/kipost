import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/components/kipost_button.dart';
import 'package:kipost/components/kipost_textfield.dart';
import 'package:kipost/controllers/app_controller.dart';
import 'package:kipost/controllers/auth_controller.dart';
import 'package:kipost/app_route.dart';
import 'package:kipost/theme/app_colors.dart';
import 'package:kipost/utils/snackbar_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AppController appController = Get.find<AppController>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _isClient = true; // Par défaut client
  bool _isProvider = false; // Optionnel prestataire

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      SnackbarHelper.showError(
        title: 'Erreur',
        message: 'Vous devez accepter les conditions d\'utilisation',
      );
      return;
    }

    if (!_isClient && !_isProvider) {
      SnackbarHelper.showError(
        title: 'Erreur',
        message: 'Vous devez sélectionner au moins un rôle',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthController.to.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _isClient,
        _isProvider,
      );
      SnackbarHelper.showSuccess(
        title: 'Succès',
        message: 'Compte créé avec succès',
      );
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('weak-password')) {
        errorMessage = 'Le mot de passe est trop faible';
      } else if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Cet email est déjà utilisé';
      }

      SnackbarHelper.showError(
        title: 'Erreur',
        message: errorMessage,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  getLoacation() {
    appController.checkLocationAndInitialize();
  }

  @override
  void initState() {
    super.initState();
    getLoacation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Iconsax.arrow_left,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // En-tête moderne
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Iconsax.user_add,
                            size: 60,
                            color: AppColors.onPrimary,
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'Créer un compte',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Rejoignez la communauté Kipost',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Formulaire d'inscription
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        KipostTextField(
                          controller: _nameController,
                          label: 'Nom complet',
                          icon: Iconsax.user,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre nom';
                            }
                            if (value.length < 2) {
                              return 'Le nom doit contenir au moins 2 caractères';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Role selection
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.user_tag,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Je souhaite :',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              CheckboxListTile(
                                title: const Text('Rechercher des services'),
                                subtitle: const Text(
                                  'Poster des annonces (Client)',
                                ),
                                value: _isClient,
                                onChanged: (value) {
                                  setState(() {
                                    _isClient = value ?? true;
                                  });
                                },
                                activeColor: AppColors.primary,
                                contentPadding: EdgeInsets.zero,
                              ),
                              CheckboxListTile(
                                title: const Text('Proposer des services'),
                                subtitle: const Text(
                                  'Répondre aux annonces (Prestataire)',
                                ),
                                value: _isProvider,
                                onChanged: (value) {
                                  setState(() {
                                    _isProvider = value ?? false;
                                  });
                                },
                                activeColor: AppColors.primary,
                                contentPadding: EdgeInsets.zero,
                              ),
                              if (!_isClient && !_isProvider)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Vous devez sélectionner au moins un rôle',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        KipostTextField(
                          controller: _emailController,
                          label: 'Adresse email',
                          icon: Iconsax.sms,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre email';
                            }
                            if (!GetUtils.isEmail(value)) {
                              return 'Veuillez saisir un email valide';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        KipostTextField(
                          controller: _passwordController,
                          label: 'Mot de passe',
                          obscureText: true,
                          icon: Iconsax.lock,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir un mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        KipostTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmer le mot de passe',
                          obscureText: true,
                          icon: Iconsax.lock_1,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez confirmer votre mot de passe';
                            }
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Checkbox conditions d'utilisation
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() => _acceptTerms = value ?? false);
                              },
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'J\'accepte les ',
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'conditions d\'utilisation',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' et la ',
                                      style: TextStyle(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'politique de confidentialité',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Bouton d'inscription
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: KipostButton(
                            label:
                                _isLoading ? 'Création...' : 'Créer mon compte',
                            onPressed: _isLoading ? null : _register,
                            icon: Iconsax.user_add,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Séparateur
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.outlineVariant,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppColors.outlineVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Lien vers connexion
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Get.toNamed(AppRoutes.login),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.login,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Déjà un compte ? Se connecter",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
