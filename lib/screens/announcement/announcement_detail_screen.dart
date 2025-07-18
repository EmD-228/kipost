import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:kipost/services/announcement_service.dart';
import 'package:kipost/services/auth_service.dart';
import 'package:kipost/components/announcement/announcement_widgets.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({super.key});

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final AnnouncementService _announcementService = AnnouncementService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final argument = Get.arguments;
    print('🔍 DEBUG: Received argument: $argument');
    return FutureBuilder<AnnouncementModel?>(
      future:
          argument is AnnouncementModel
              ? Future.value(argument)
              : _announcementService.getAnnouncement(argument.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chargement...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Erreur')),
            body: const Center(child: Text('Annonce non trouvée')),
          );
        }

        final ann = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Détails de l\'annonce',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left, color: Colors.black),
              onPressed: () => Get.back(),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              // État de l'annonce en haut
              SliverToBoxAdapter(
                child: AnnouncementStatusBanner(announcement: ann),
              ),

              // Contenu principal
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec titre et statut
                        AnnouncementHeader(announcement: ann),
                        const SizedBox(height: 24),

                        // Description
                        AnnouncementDescriptionSection(announcement: ann),
                        const SizedBox(height: 24),
                        // Informations principales
                        AnnouncementInfoSection(announcement: ann),

                        const SizedBox(height: 32),

                        // Actions utilisateur
                        ..._buildUserActions(ann),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildUserActions(AnnouncementModel ann) {
    // Check if current user is the owner using correct property names
    final isOwner = _authService.currentUser?.id == ann.clientId;

    if (isOwner) {
      return [OwnerActionsSection(announcement: ann)];
    } else {
      return [ProviderActionsSection(announcement: ann)];
    }
  }
}
