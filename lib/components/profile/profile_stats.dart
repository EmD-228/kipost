import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfileStats extends StatelessWidget {
  final String announcesCount;
  final String proposalsCount;
  final String workInProgressCount;

  const ProfileStats({
    super.key,
    required this.announcesCount,
    required this.proposalsCount,
    required this.workInProgressCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          announcesCount,
          'Annonces',
          Iconsax.briefcase,
          Colors.blue,
        ),
        _buildStatCard(
          proposalsCount,
          'Propositions',
          Iconsax.note_2,
          Colors.green,
        ),
        _buildStatCard(
          workInProgressCount,
          'En cours',
          Iconsax.clock,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
