import 'package:flutter/material.dart';
import 'package:kipost/services/auth_service.dart';
import 'package:kipost/services/profile_service.dart';
import 'package:kipost/models/supabase/profile_model.dart';
import 'package:kipost/components/profile/profile_widgets.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  ProfileModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _profileService.getCurrentProfile();
      if (mounted) {
        setState(() {
          currentUser = user;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // En-tête du profil
              ProfileHeader(
                currentUser: currentUser,
                authService: _authService,
                announcesCount: '0', // TODO: Compter les vraies annonces
                proposalsCount: '0', // TODO: Compter les propositions
                workInProgressCount: '0', // TODO: Compter les travaux en cours
              ),
              const SizedBox(height: 20),

              // Options du profil
              ProfileOptionsSection(
                onProfileUpdated: _loadUserProfile,
              ),

              const SizedBox(height: 20),

              // Paramètres
              const ProfileSettingsSection(),

              const SizedBox(height: 20),

              // Bouton de déconnexion
              ProfileLogoutButton(
                authService: _authService,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
