import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kipost/models/supabase/supabase_models.dart';

class ProviderInfoCard extends StatelessWidget {
  final ProposalModel proposal;

  const ProviderInfoCard({
    super.key,
    required this.proposal,
  });

  @override
  Widget build(BuildContext context) {
    final provider = proposal.provider;
    
    if (provider == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.profile_circle,
                color: Colors.purple.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Informations du postulant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Avatar et nom
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.purple.shade100,
                backgroundImage: provider.avatarUrl != null && provider.avatarUrl!.isNotEmpty
                    ? NetworkImage(provider.avatarUrl!)
                    : null,
                child: provider.avatarUrl == null || provider.avatarUrl!.isEmpty
                    ? Text(
                        provider.initials,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            provider.city ?? 'Localisation non renseignée',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Informations supplémentaires
          if (provider.averageRating != null) ...[
            Row(
              children: [
                Icon(
                  Iconsax.star1,
                  size: 16,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Note: ${provider.averageRating!.toStringAsFixed(1)}/5',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          if (provider.isVerified) ...[
            Row(
              children: [
                Icon(
                  Iconsax.shield_tick,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Profil vérifié',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          if (provider.completedContracts != null) ...[
            Row(
              children: [
                Icon(
                  Iconsax.task_square,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contrats terminés: ${provider.completedContracts}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Skills
          if (provider.skills != null && provider.skills!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.code_circle,
                  size: 16,
                  color: Colors.indigo.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Compétences:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: provider.skills!.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
          
          // Portfolio Images
          if (provider.portfolioImages != null && provider.portfolioImages!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.image,
                  size: 16,
                  color: Colors.pink.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Portfolio:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.portfolioImages!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        provider.portfolioImages![index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Iconsax.image,
                              color: Colors.grey.shade400,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Badge de statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.verify,
                  size: 16,
                  color: Colors.purple.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Postulant',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
