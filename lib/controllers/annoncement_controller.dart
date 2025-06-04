import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kipost/models/announcement.dart';

class AnnouncementController extends GetxController {
  final RxBool loading = false.obs;
  final RxList<Map<String, dynamic>> announcements =
      <Map<String, dynamic>>[].obs;

  // Création d'annonce (déjà présent)
  Future<void> createAnnouncement({
    required String title,
    required String description,
    required String category,
    required String location,
  }) async {
    loading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('annonces').add({
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'ouverte',
        'creatorId': user?.uid,
        'creatorEmail': user?.email,
        'proposalIds': [], // Initialize empty list for proposal IDs
      });
      loading.value = false;
      Get.back();
      Get.snackbar(
        'Succès',
        'Annonce créée avec succès !',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      loading.value = false;
      Get.snackbar(
        'Erreur',
        'Erreur lors de la création : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  // Récupérer toutes les annonces
  Stream<QuerySnapshot<Map<String, dynamic>>> getAnnouncementsStream() {
    return FirebaseFirestore.instance
        .collection('annonces')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Supprimer une annonce
  Future<void> deleteAnnouncement(String id) async {
    try {
      await FirebaseFirestore.instance.collection('annonces').doc(id).delete();
      Get.snackbar(
        'Succès',
        'Annonce supprimée',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la suppression : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  // Récupérer une annonce par ID
  Future<Announcement?> getAnnouncementById(String id) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('annonces').doc(id).get();
      if (doc.exists) {
        return Announcement.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la récupération : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
    return null;
  }

  // Récupérer les annonces d'un utilisateur
  Stream<List<Announcement>> getUserAnnouncements(String userId) {
    return FirebaseFirestore.instance
        .collection('annonces')
        .where('creatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Announcement.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Nouvelle méthode pour que le créateur sélectionne un prestataire
  Future<void> selectServiceProvider(String announcementId, String selectedProposalId, String selectedUserId) async {
    try {
      // Mettre à jour l'annonce avec le prestataire sélectionné
      await FirebaseFirestore.instance
          .collection('annonces')
          .doc(announcementId)
          .update({
            'status': 'attribuée',
            'selectedProviderId': selectedUserId,
            'selectedProposalId': selectedProposalId,
          });

      // Mettre à jour la proposition sélectionnée
      await FirebaseFirestore.instance
          .collection('proposals')
          .doc(selectedProposalId)
          .update({'status': 'acceptée'});

      // Rejeter toutes les autres propositions
      final otherProposals = await FirebaseFirestore.instance
          .collection('proposals')
          .where('announcementId', isEqualTo: announcementId)
          .where('status', isEqualTo: 'en_attente')
          .get();

      for (var doc in otherProposals.docs) {
        if (doc.id != selectedProposalId) {
          await doc.reference.update({'status': 'refusée'});
        }
      }

      Get.snackbar('Succès', 'Prestataire sélectionné !',
          backgroundColor: Colors.green.shade100, colorText: Colors.black);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de la sélection : $e',
          backgroundColor: Colors.red.shade100, colorText: Colors.black);
    }
  }

  // Méthode pour récupérer les propositions d'une annonce
  Stream<List<Map<String, dynamic>>> getAnnouncementProposalsStream(String announcementId) {
    return FirebaseFirestore.instance
        .collection('proposals')
        .where('announcementId', isEqualTo: announcementId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  // Méthode utilitaire pour s'assurer que toutes les annonces ont le champ proposalIds
  Future<void> ensureProposalIdsField() async {
    try {
      final announcements = await FirebaseFirestore.instance
          .collection('annonces')
          .get();
      
      final batch = FirebaseFirestore.instance.batch();
      int updatedCount = 0;
      
      for (final doc in announcements.docs) {
        final data = doc.data();
        if (!data.containsKey('proposalIds')) {
          batch.update(doc.reference, {
            'proposalIds': [],
          });
          updatedCount++;
        }
      }
      
      if (updatedCount > 0) {
        await batch.commit();
        print('Updated $updatedCount announcements with proposalIds field');
        Get.snackbar(
          'Migration',
          'Mis à jour $updatedCount annonces avec le champ proposalIds',
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.black,
        );
      } else {
        print('All announcements already have proposalIds field');
      }
    } catch (e) {
      print('Error ensuring proposalIds field: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la vérification : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }
}
