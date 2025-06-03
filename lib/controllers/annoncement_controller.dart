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

  Future<void> acceptAnnouncement(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('annonces')
          .doc(id)
          .update({'status': 'acceptée'});
      Get.back();
      Get.snackbar('Succès', 'Annonce acceptée !',
          backgroundColor: Colors.green.shade100, colorText: Colors.black);
    } catch (e) {
      Get.snackbar('Erreur', 'Erreur lors de l\'acceptation : $e',
          backgroundColor: Colors.red.shade100, colorText: Colors.black);
    }
  }
}
