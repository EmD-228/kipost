import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kipost/models/work_details.dart';
import '../utils/app_status.dart';

class WorkController extends GetxController {
  final RxBool loading = false.obs;

  // Créer les détails du travail après acceptation d'une proposition
  Future<String?> scheduleWork({
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
        status: WorkStatus.planned,
        createdAt: DateTime.now(),
      );

     final docRef =   await FirebaseFirestore.instance
          .collection('work_details')
          .add(workDetails.toMap());

     
      // Get.back();
     
       return docRef.id;
    } catch (e) {
     
     
       return null;
    }
  }

  // ============ CALENDAR LOGIC ============

  // Obtenir tous les travaux planifiés pour un mois donné
  Future<List<WorkDetails>> getWorksByMonth(DateTime month) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final clientQuery = FirebaseFirestore.instance
          .collection('work_details')
          .where('clientId', isEqualTo: user.uid)
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));

      final providerQuery = FirebaseFirestore.instance
          .collection('work_details')
          .where('providerId', isEqualTo: user.uid)
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));

      final clientResults = await clientQuery.get();
      final providerResults = await providerQuery.get();

      final allWorks = <WorkDetails>[];
      
      for (final doc in clientResults.docs) {
        allWorks.add(WorkDetails.fromMap(doc.data(), doc.id));
      }
      
      for (final doc in providerResults.docs) {
        final workDetail = WorkDetails.fromMap(doc.data(), doc.id);
        // Éviter les doublons si l'utilisateur est à la fois client et prestataire
        if (!allWorks.any((w) => w.id == workDetail.id)) {
          allWorks.add(workDetail);
        }
      }

      return allWorks;
    } catch (e) {
      print('Erreur lors de la récupération des travaux du mois : $e');
      return [];
    }
  }

  // Obtenir les travaux planifiés pour une date spécifique
  Future<List<WorkDetails>> getWorksByDate(DateTime date) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final clientQuery = FirebaseFirestore.instance
          .collection('work_details')
          .where('clientId', isEqualTo: user.uid)
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));

      final providerQuery = FirebaseFirestore.instance
          .collection('work_details')
          .where('providerId', isEqualTo: user.uid)
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));

      final clientResults = await clientQuery.get();
      final providerResults = await providerQuery.get();

      final allWorks = <WorkDetails>[];
      
      for (final doc in clientResults.docs) {
        allWorks.add(WorkDetails.fromMap(doc.data(), doc.id));
      }
      
      for (final doc in providerResults.docs) {
        final workDetail = WorkDetails.fromMap(doc.data(), doc.id);
        if (!allWorks.any((w) => w.id == workDetail.id)) {
          allWorks.add(workDetail);
        }
      }

      return allWorks;
    } catch (e) {
      print('Erreur lors de la récupération des travaux du jour : $e');
      return [];
    }
  }

  // Vérifier les conflits d'horaires pour une date et heure données
  Future<bool> hasTimeConflict({
    required DateTime date,
    required String time,
    String? excludeWorkId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final worksOnDate = await getWorksByDate(date);
      
      for (final work in worksOnDate) {
        // Exclure le travail en cours de modification
        if (excludeWorkId != null && work.id == excludeWorkId) continue;
        
        // Vérifier si l'utilisateur est impliqué dans ce travail
        if (work.clientId == user.uid || work.providerId == user.uid) {
          if (work.scheduledTime == time) {
            return true; // Conflit détecté
          }
        }
      }
      
      return false; // Pas de conflit
    } catch (e) {
      print('Erreur lors de la vérification des conflits : $e');
      return false;
    }
  }

  // Obtenir les créneaux disponibles pour une date donnée
  Future<List<String>> getAvailableTimeSlots(DateTime date) async {
    try {
      const workingHours = [
        '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
        '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
        '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
        '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
      ];

      final worksOnDate = await getWorksByDate(date);
      final bookedTimes = worksOnDate
          .where((work) => work.scheduledTime != null)
          .map((work) => work.scheduledTime!)
          .toSet();

      return workingHours.where((time) => !bookedTimes.contains(time)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des créneaux disponibles : $e');
      return [];
    }
  }

  // Obtenir les statistiques du calendrier pour un mois
  Future<Map<String, int>> getCalendarStats(DateTime month) async {
    try {
      final works = await getWorksByMonth(month);
      
      final stats = <String, int>{
        'total': works.length,
        'planned': 0,
        'inProgress': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final work in works) {
        switch (work.status) {
          case WorkStatus.planned:
            stats['planned'] = (stats['planned'] ?? 0) + 1;
            break;
          case WorkStatus.inProgress:
            stats['inProgress'] = (stats['inProgress'] ?? 0) + 1;
            break;
          case WorkStatus.completed:
            stats['completed'] = (stats['completed'] ?? 0) + 1;
            break;
          case WorkStatus.cancelled:
            stats['cancelled'] = (stats['cancelled'] ?? 0) + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      print('Erreur lors du calcul des statistiques : $e');
      return {'total': 0, 'planned': 0, 'inProgress': 0, 'completed': 0, 'cancelled': 0};
    }
  }

  // Reprogrammer un travail
  Future<bool> rescheduleWork({
    required String workId,
    required DateTime newDate,
    required String newTime,
    String? newLocation,
    String? rescheduleReason,
  }) async {
    try {
      // Vérifier les conflits d'horaires
      final hasConflict = await hasTimeConflict(
        date: newDate,
        time: newTime,
        excludeWorkId: workId,
      );

      if (hasConflict) {
        Get.snackbar(
          'Conflit d\'horaire',
          'Ce créneau est déjà occupé. Veuillez choisir un autre horaire.',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.black,
        );
        return false;
      }

      final updateData = <String, dynamic>{
        'scheduledDate': Timestamp.fromDate(newDate),
        'scheduledTime': newTime,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (newLocation != null) {
        updateData['workLocation'] = newLocation;
      }

      if (rescheduleReason != null) {
        updateData['rescheduleReason'] = rescheduleReason;
        updateData['rescheduledAt'] = FieldValue.serverTimestamp();
      }

      await FirebaseFirestore.instance
          .collection('work_details')
          .doc(workId)
          .update(updateData);

      Get.snackbar(
        'Succès',
        'Travail reprogrammé avec succès',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );

      return true;
    } catch (e) {
      print('Erreur lors de la reprogrammation : $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la reprogrammation : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      return false;
    }
  }

  // Obtenir les prochains travaux (dans les 7 prochains jours)
  Future<List<WorkDetails>> getUpcomingWorks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      final clientQuery = FirebaseFirestore.instance
          .collection('work_details')
          .where('clientId', isEqualTo: user.uid)
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(nextWeek))
          .where('status', whereIn: [WorkStatus.planned, WorkStatus.inProgress])
          .orderBy('scheduledDate');

      final providerQuery = FirebaseFirestore.instance
          .collection('work_details')
          .where('providerId', isEqualTo: user.uid)
          .where('scheduledDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(nextWeek))
          .where('status', whereIn: [WorkStatus.planned, WorkStatus.inProgress])
          .orderBy('scheduledDate');

      final clientResults = await clientQuery.get();
      final providerResults = await providerQuery.get();

      final allWorks = <WorkDetails>[];
      
      for (final doc in clientResults.docs) {
        allWorks.add(WorkDetails.fromMap(doc.data(), doc.id));
      }
      
      for (final doc in providerResults.docs) {
        final workDetail = WorkDetails.fromMap(doc.data(), doc.id);
        if (!allWorks.any((w) => w.id == workDetail.id)) {
          allWorks.add(workDetail);
        }
      }

      // Trier par date et heure
      allWorks.sort((a, b) {
        if (a.scheduledDate == null || b.scheduledDate == null) return 0;
        final dateComparison = a.scheduledDate!.compareTo(b.scheduledDate!);
        if (dateComparison != 0) return dateComparison;
        
        // Si même date, trier par heure
        if (a.scheduledTime != null && b.scheduledTime != null) {
          return a.scheduledTime!.compareTo(b.scheduledTime!);
        }
        return 0;
      });

      return allWorks;
    } catch (e) {
      print('Erreur lors de la récupération des prochains travaux : $e');
      return [];
    }
  }

  // ============ END CALENDAR LOGIC ============

  // Récupérer les détails du travail pour une proposition
  Future<WorkDetails?> getWorkDetailsByProposal(String proposalId) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
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
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => WorkDetails.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Stream des travaux pour le prestataire (propositions acceptées)
  Stream<List<WorkDetails>> getProviderWorkStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('work_details')
        .where('providerId', isEqualTo: user?.uid)
        .orderBy('scheduledDate', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => WorkDetails.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Mettre à jour le statut du travail
  Future<void> updateWorkStatus(String workId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('work_details')
          .doc(workId)
          .update({
            'status': status,
            if (status == WorkStatus.completed)
              'completedAt': FieldValue.serverTimestamp(),
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
            'status': WorkStatus.cancelled,
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

  // Créer un nouveau work_details et retourner l'ID du document
  Future<String?> createWorkDetails({
    required String proposalId,
    required String announcementId,
    required String clientId,
    required String providerId,
  }) async {
    try {
      final workDetails = {
        'proposalId': proposalId,
        'announcementId': announcementId,
        'clientId': clientId,
        'providerId': providerId,
        'status': WorkStatus.planned,
        'createdAt': FieldValue.serverTimestamp(),
        'scheduledDate': null,
        'scheduledTime': null,
        'workLocation': null,
        'additionalNotes': null,
      };

      final docRef = await FirebaseFirestore.instance
          .collection('work_details')
          .add(workDetails);

      print('🔍 DEBUG: Work details created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Erreur lors de la création du work_details : $e');
      return null;
    }
  }
}
