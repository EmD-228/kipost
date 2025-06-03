import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:kipost/models/announcement.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback? onTap;
  const AnnouncementCard({Key? key, required this.announcement, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Icon(Iconsax.document, color: Colors.deepPurple, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                announcement.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                announcement.category,
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          announcement.description,
                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      announcement.status,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 12),
                    ),
                    backgroundColor: Colors.deepPurple.shade50,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Iconsax.location, color: Colors.deepPurple, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    announcement.location,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  const Spacer(),
                  Icon(Iconsax.clock, color: Colors.deepPurple, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(announcement.createdAt),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(width: 4),
                  Icon(Iconsax.arrow_right_3, color: Colors.deepPurple, size: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return 'Aujourd\'hui';
    } else if (now.difference(date).inDays == 1) {
      return 'Hier';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}
