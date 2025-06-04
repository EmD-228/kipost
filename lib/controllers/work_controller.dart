import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kipost/models/work_details.dart';

class WorkController extends GetxController {
  final RxBool loading = false.obs;

  // Créer les détails du travail après acceptation d'une proposition
  Future<void> scheduleWork({
    required String proposalId,
    required String announcementId,
    required String clientId,
    required String providerId,
    required DateTime scheduledDate,
    required String scheduledTime,
    required String workLocation,
    String? additionalNotes,
  }) async {
    loading.value = true;
    try {
      final workDetails = WorkDetails(
        id: '',
        proposalId: proposalId,
        announcementId: announcementId,
        clientId: clientId,
        providerId: providerId,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        workLocation: workLocation,
        additionalNotes: additionalNotes,
        status: 'planned',
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('work_details')
          .add(workDetails.toMap());

      loading.value = false;
      Get.back();
      Get.snackbar(
        'Succès',
        'Travail planifié avec succès !',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      loading.value = false;
      Get.snackbar(
        'Erreur',
        'Erreur lors de la planification : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  // Récupérer les détails du travail pour une proposition
  Future<WorkDetails?> getWorkDetailsByProposal(String proposalId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('work_details')
          .where('proposalId', isEqualTo: proposalId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return WorkDetails.fromMap(doc.data(), doc.id);
      }
    } catch (e) {
      print('Erreur lors de la récupération des détails du travail : $e');
    }
    return null;
  }

  // Stream des travaux pour le client (annonces créées par l'utilisateur)
  Stream<List<WorkDetails>> getClientWorkStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('work_details')
        .where('clientId', isEqualTo: user?.uid)
        .orderBy('scheduledDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkDetails.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Stream des travaux pour le prestataire (propositions acceptées)
  Stream<List<WorkDetails>> getProviderWorkStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('work_details')
        .where('providerId', isEqualTo: user?.uid)
        .orderBy('scheduledDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkDetails.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Mettre à jour le statut du travail
  Future<void> updateWorkStatus(String workId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('work_details')
          .doc(workId)
          .update({
        'status': status,
        if (status == 'completed') 'completedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Succès',
        'Statut mis à jour !',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la mise à jour : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  // Modifier les détails du travail
  Future<void> updateWorkDetails({
    required String workId,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? workLocation,
    String? additionalNotes,
  }) async {
    loading.value = true;
    try {
      final updateData = <String, dynamic>{};
      
      if (scheduledDate != null) {
        updateData['scheduledDate'] = Timestamp.fromDate(scheduledDate);
      }
      if (scheduledTime != null) {
        updateData['scheduledTime'] = scheduledTime;
      }
      if (workLocation != null) {
        updateData['workLocation'] = workLocation;
      }
      if (additionalNotes != null) {
        updateData['additionalNotes'] = additionalNotes;
      }

      await FirebaseFirestore.instance
          .collection('work_details')
          .doc(workId)
          .update(updateData);

      loading.value = false;
      Get.snackbar(
        'Succès',
        'Détails mis à jour !',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      loading.value = false;
      Get.snackbar(
        'Erreur',
        'Erreur lors de la mise à jour : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  // Annuler un travail
  Future<void> cancelWork(String workId, String reason) async {
    try {
      await FirebaseFirestore.instance
          .collection('work_details')
          .doc(workId)
          .update({
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Information',
        'Travail annulé',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'annulation : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }
}
