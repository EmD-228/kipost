import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/services/proposal_service.dart';
import 'package:kipost/models/supabase/supabase_models.dart';
import 'package:kipost/utils/app_status.dart';
import 'package:kipost/components/announcement/proposal_dialog.dart';

class ProviderActionsSection extends StatelessWidget {
  final AnnouncementModel announcement;
  final ProposalService _proposalService = ProposalService();

  ProviderActionsSection({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Postuler à cette annonce',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        if (announcement.status == AnnouncementStatus.active)
          FutureBuilder<bool>(
            future: _proposalService.hasUserAlreadyApplied(announcement.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              final hasApplied = snapshot.data ?? false;

              if (hasApplied) {
                return _buildAlreadyAppliedWidget();
              }

              return _buildApplyButton();
            },
          )
        else
          _buildClosedAnnouncementWidget(),
      ],
    );
  }

  Widget _buildAlreadyAppliedWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.tick_circle,
              color: Colors.orange.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proposition envoyée !',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vous avez déjà postulé pour cette annonce. Le créateur examinera votre proposition.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Builder(
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.green.shade400],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => ProposalDialog.show(context, announcement.id),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.send_1,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Postuler maintenant',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Présentez votre candidature',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Iconsax.arrow_right_3,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildClosedAnnouncementWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.lock, color: Colors.grey.shade600, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.status == AnnouncementStatus.completed
                      ? 'Annonce terminée'
                      : announcement.status == AnnouncementStatus.cancelled
                      ? 'Annonce annulée'
                      : announcement.status == AnnouncementStatus.paused
                      ? 'Annonce en pause'
                      : announcement.status == AnnouncementStatus.expired
                      ? 'Annonce expirée'
                      : 'Annonce fermée',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.status == AnnouncementStatus.completed
                      ? 'Cette annonce a été terminée avec succès'
                      : announcement.status == AnnouncementStatus.cancelled
                      ? 'Cette annonce a été annulée'
                      : announcement.status == AnnouncementStatus.paused
                      ? 'Cette annonce est temporairement en pause'
                      : announcement.status == AnnouncementStatus.expired
                      ? 'Cette annonce a expiré'
                      : 'Cette annonce n\'est plus disponible',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
