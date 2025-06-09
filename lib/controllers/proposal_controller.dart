import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/proposal.dart';
import '../models/announcement.dart';

class ProposalController extends GetxController {
  final RxList<Proposal> proposals = <Proposal>[].obs;
  final RxBool loading = false.obs;

  // Get announcement data separately if needed
  Future<Announcement?> getAnnouncementForProposal(String announcementId) async {
    try {
      final announcementDoc = await FirebaseFirestore.instance
          .collection('annonces')
          .doc(announcementId)
          .get();
      
      if (announcementDoc.exists) {
        return Announcement.fromMap(announcementDoc.data()!, announcementDoc.id);
      }
    } catch (e) {
      print('🔍 DEBUG: Error getting announcement: $e');
    }
    
    return null;
  }

  Future<List<Proposal>> getUserProposals() async {
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 DEBUG: getUserProposals called for user: ${user?.uid}');
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('proposals')
          .where('userId', isEqualTo: user?.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      print('🔍 DEBUG: Received ${snapshot.docs.length} proposals from Firestore');
      
      final proposalsList = <Proposal>[];
      for (final doc in snapshot.docs) {
        print('🔍 DEBUG: Processing proposal doc: ${doc.id} with data: ${doc.data()}');
        final proposal = Proposal.fromMap(doc.data(), doc.id);
        proposalsList.add(proposal);
      }
      
      print('🔍 DEBUG: Converted to ${proposalsList.length} Proposal objects');
      return proposalsList;
    } catch (e) {
      print('🔍 DEBUG: Error getting user proposals: $e');
      return [];
    }
  }

  // Vérifier si l'utilisateur a déjà postulé pour cette annonce
  Future<bool> hasUserAlreadyApplied(String announcementId) async {
    final user = FirebaseAuth.instance.currentUser;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('proposals')
        .where('announcementId', isEqualTo: announcementId)
        .where('userId', isEqualTo: user?.uid)
        .get();
    
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> sendProposal({
    required String announcementId,
    required String message,
  }) async {
    loading.value = true;
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 DEBUG: sendProposal called for user: ${user?.uid}, announcement: $announcementId');

    try {
      // Vérifier si l'utilisateur a déjà postulé
      final hasApplied = await hasUserAlreadyApplied(announcementId);
      print('🔍 DEBUG: hasUserAlreadyApplied result: $hasApplied');
      
      if (hasApplied) {
        loading.value = false;
        Get.snackbar('Information', 'Vous avez déjà postulé pour cette annonce !', 
            backgroundColor: Get.theme.colorScheme.secondaryContainer);
        return;
      }

      final proposalData = {
        'announcementId': announcementId,
        'userId': user?.uid,
        'userEmail': user?.email,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'en_attente',
      };
      
      print('🔍 DEBUG: Creating proposal with data: $proposalData');
      
      // Utiliser une transaction pour assurer la cohérence des données
      final batch = FirebaseFirestore.instance.batch();
      
      // Créer la proposition
      final proposalRef = FirebaseFirestore.instance.collection('proposals').doc();
      batch.set(proposalRef, proposalData);
      
      // Mettre à jour l'annonce pour ajouter l'ID de la proposition
      final announcementRef = FirebaseFirestore.instance.collection('annonces').doc(announcementId);
      batch.update(announcementRef, {
        'proposalIds': FieldValue.arrayUnion([proposalRef.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Exécuter la transaction
      await batch.commit();
      
      print('🔍 DEBUG: Proposal created successfully with ID: ${proposalRef.id}');
      print('🔍 DEBUG: Announcement updated with proposal ID: ${proposalRef.id}');
      
      loading.value = false;
      Get.snackbar('Succès', 'Proposition envoyée !', backgroundColor: Get.theme.colorScheme.secondaryContainer);
    } catch (e) {
      if (kDebugMode) {
        print('🔍 DEBUG: Error sending proposal: $e');
      }
      loading.value = false;
      Get.snackbar('Erreur', 'Erreur lors de l\'envoi : $e', backgroundColor: Get.theme.colorScheme.errorContainer);
    }
  }

  Future<List<Proposal>> getReceivedProposals() async {
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 DEBUG: getReceivedProposals called for user: ${user?.uid}');
    
    if (user?.uid == null) {
      return [];
    }
    
    try {
      // Récupérer les IDs des annonces de l'utilisateur
      final userAnnouncementsQuery = await FirebaseFirestore.instance
          .collection('annonces')
          .where('creatorId', isEqualTo: user!.uid)
          .get();
      
      final userAnnouncementIds = userAnnouncementsQuery.docs.map((doc) => doc.id).toList();
      print('🔍 DEBUG: User owns ${userAnnouncementIds.length} announcements');
      
      if (userAnnouncementIds.isEmpty) {
        return [];
      }
      
      // Récupérer les propositions pour ces annonces
      final proposalSnapshot = await FirebaseFirestore.instance
          .collection('proposals')
          .where('announcementId', whereIn: userAnnouncementIds)
          .orderBy('createdAt', descending: true)
          .get();
      
      print('🔍 DEBUG: Received ${proposalSnapshot.docs.length} received proposals from Firestore');
      
      final proposalsList = <Proposal>[];
      for (final doc in proposalSnapshot.docs) {
        print('🔍 DEBUG: Processing received proposal doc: ${doc.id}');
        final proposal = Proposal.fromMap(doc.data(), doc.id);
        proposalsList.add(proposal);
      }
      
      print('🔍 DEBUG: Converted to ${proposalsList.length} received Proposal objects');
      return proposalsList;
    } catch (e) {
      print('🔍 DEBUG: Error getting received proposals: $e');
      return [];
    }
  }

  // ANCIENNE MÉTHODE - gardée pour compatibilité
  Stream<List<Proposal>> getReceivedProposalsStreamOld() {
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 DEBUG: getReceivedProposalsStream called for user: ${user?.uid}');
    
    // D'abord, on récupère les annonces de l'utilisateur connecté
    return FirebaseFirestore.instance
        .collection('annonces')
        .where('creatorId', isEqualTo: user?.uid)
        .snapshots()
        .asyncExpand((announcementSnapshot) {
          if (announcementSnapshot.docs.isEmpty) {
            print('🔍 DEBUG: No announcements found for user');
            return Stream.value(<Proposal>[]);
          }
          
          // Extraire les IDs des annonces
          final announcementIds = announcementSnapshot.docs.map((doc) => doc.id).toList();
          print('🔍 DEBUG: Found ${announcementIds.length} announcements: $announcementIds');
          
          // Récupérer les propositions pour ces annonces
          return FirebaseFirestore.instance
              .collection('proposals')
              .where('announcementId', whereIn: announcementIds)
              .orderBy('createdAt', descending: true)
              .snapshots()
              .map((proposalSnapshot) {
                print('🔍 DEBUG: Received ${proposalSnapshot.docs.length} received proposals from Firestore');
                
                final proposalsList = <Proposal>[];
                for (final doc in proposalSnapshot.docs) {
                  print('🔍 DEBUG: Processing received proposal doc: ${doc.id} with data: ${doc.data()}');
                  final proposal = Proposal.fromMap(doc.data(), doc.id);
                  proposalsList.add(proposal);
                }
                
                print('🔍 DEBUG: Converted to ${proposalsList.length} received Proposal objects');
                return proposalsList;
              });
        });
  }

  // Mettre à jour le statut d'une proposition
  Future<void> updateProposalStatus(String proposalId, String newStatus) async {
    try {
      print('🔍 DEBUG: Updating proposal $proposalId to status: $newStatus');
      
      await FirebaseFirestore.instance
          .collection('proposals')
          .doc(proposalId)
          .update({
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      await getReceivedProposals();
      print('🔍 DEBUG: Proposal status updated successfully');
    } catch (e) {
      print('🔍 DEBUG: Error updating proposal status: $e');
      throw e;
    }
  }

  // Méthode de diagnostic pour vérifier l'état des données
  Future<void> diagnoseProposalSystem() async {
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 DIAGNOSTIC: Starting proposal system diagnosis for user: ${user?.uid}');
    
    try {
      // Vérifier les annonces de l'utilisateur
      final userAnnouncements = await FirebaseFirestore.instance
          .collection('annonces')
          .where('creatorId', isEqualTo: user?.uid)
          .get();
      
      print('🔍 DIAGNOSTIC: Found ${userAnnouncements.docs.length} announcements for user');
      
      for (final doc in userAnnouncements.docs) {
        final data = doc.data();
        print('🔍 DIAGNOSTIC: Announcement ${doc.id}:');
        print('  - Title: ${data['title']}');
        print('  - Has proposalIds: ${data.containsKey('proposalIds')}');
        if (data.containsKey('proposalIds')) {
          final proposalIds = List<String>.from(data['proposalIds'] ?? []);
          print('  - ProposalIds count: ${proposalIds.length}');
          print('  - ProposalIds: $proposalIds');
        }
      }
      
      // Vérifier les propositions reçues
      final allProposals = await FirebaseFirestore.instance
          .collection('proposals')
          .get();
      
      print('🔍 DIAGNOSTIC: Total proposals in database: ${allProposals.docs.length}');
      
      // Compter les propositions par annonce
      final proposalsByAnnouncement = <String, int>{};
      for (final doc in allProposals.docs) {
        final announcementId = doc.data()['announcementId'] as String?;
        if (announcementId != null) {
          proposalsByAnnouncement[announcementId] = (proposalsByAnnouncement[announcementId] ?? 0) + 1;
        }
      }
      
      print('🔍 DIAGNOSTIC: Proposals by announcement: $proposalsByAnnouncement');
      
    } catch (e) {
      print('🔍 DIAGNOSTIC ERROR: $e');
    }
  }

  // Get proposal by ID
  Future<Proposal?> getProposalById(String proposalId) async {
    try {
      print('🔍 DEBUG: getProposalById called for ID: $proposalId');
      
      final proposalDoc = await FirebaseFirestore.instance
          .collection('proposals')
          .doc(proposalId)
          .get();
      
      if (proposalDoc.exists) {
        print('🔍 DEBUG: Proposal found with data: ${proposalDoc.data()}');
        return Proposal.fromMap(proposalDoc.data()!, proposalDoc.id);
      } else {
        print('🔍 DEBUG: No proposal found with ID: $proposalId');
        return null;
      }
    } catch (e) {
      print('🔍 DEBUG: Error getting proposal by ID: $e');
      return null;
    }
  }
}
