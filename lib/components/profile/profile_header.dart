import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/profile_model.dart';
import 'package:kipost/services/auth_service.dart';
import 'package:kipost/components/profile/profile_stats.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileModel? currentUser;
  final AuthService authService;
  final String announcesCount;
  final String proposalsCount;
  final String workInProgressCount;

  const ProfileHeader({
    super.key,
    required this.currentUser,
    required this.authService,
    this.announcesCount = '0',
    this.proposalsCount = '0',
    this.workInProgressCount = '0',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple,
                  Colors.deepPurple.shade300,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: currentUser?.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      currentUser!.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Iconsax.user,
                          color: Colors.white,
                          size: 40,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Iconsax.user,
                    color: Colors.white,
                    size: 40,
                  ),
          ),
          const SizedBox(height: 16),
          // Nom et email
          Column(
            children: [
              Text(
                currentUser?.fullName ?? 'Utilisateur',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                authService.currentUser?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          const SizedBox(height: 20),
          // Statistiques
          ProfileStats(
            announcesCount: announcesCount,
            proposalsCount: proposalsCount,
            workInProgressCount: workInProgressCount,
          ),
        ],
      ),
    );
  }
}
