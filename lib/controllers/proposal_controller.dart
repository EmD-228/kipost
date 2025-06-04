import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/proposal.dart';
import '../models/announcement.dart';

class ProposalController extends GetxController {
  final RxList<Proposal> proposals = <Proposal>[].obs;
  final RxBool loading = false.obs;

  // Enrichir une proposition avec les données de l'annonce si elles ne sont pas présentes
  Future<Proposal> _enrichProposalWithAnnouncement(Proposal proposal) async {
    if (proposal.announcement != null) {
      // Les données sont déjà présentes
      return proposal;
    }
    
    try {
      // Récupérer les données de l'annonce
      final announcementDoc = await FirebaseFirestore.instance
          .collection('announcements')
          .doc(proposal.announcementId)
          .get();
      
      if (announcementDoc.exists) {
        final announcement = Announcement.fromMap(announcementDoc.data()!, announcementDoc.id);
        
        // Créer une nouvelle instance avec les données enrichies
        return Proposal(
          id: proposal.id,
          announcementId: proposal.announcementId,
          userId: proposal.userId,
          userEmail: proposal.userEmail,
          message: proposal.message,
          createdAt: proposal.createdAt,
          status: proposal.status,
          announcement: announcement,
        );
      }
    } catch (e) {
      print('🔍 DEBUG: Error enriching proposal with announcement: $e');
    }
    
    // Retourner la proposition originale si on ne peut pas l'enrichir
    return proposal;
  }

  Stream<List<Proposal>> getUserProposalsStream() {
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 DEBUG: getUserProposalsStream called for user: ${user?.uid}');
    
    return FirebaseFirestore.instance
        .collection('proposals')
        .where('userId', isEqualTo: user?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          print('🔍 DEBUG: Received ${snapshot.docs.length} proposals from Firestore');
          
          final proposalsList = <Proposal>[];
          for (final doc in snapshot.docs) {
            print('🔍 DEBUG: Processing proposal doc: ${doc.id} with data: ${doc.data()}');
            final proposal = Proposal.fromMap(doc.data(), doc.id);
            final enrichedProposal = await _enrichProposalWithAnnouncement(proposal);
            proposalsList.add(enrichedProposal);
          }
          
          print('🔍 DEBUG: Converted to ${proposalsList.length} enriched Proposal objects');
          return proposalsList;
        });
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
  }  Future<void> sendProposal({
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

      // Récupérer les données de l'annonce
      final announcementDoc = await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementId)
          .get();
      
      if (!announcementDoc.exists) {
        throw Exception('Annonce non trouvée');
      }
      
      final announcement = Announcement.fromMap(announcementDoc.data()!, announcementDoc.id);
      print('🔍 DEBUG: Retrieved announcement: ${announcement.title}');

      final proposalData = {
        'announcementId': announcementId,
        'userId': user?.uid,
        'userEmail': user?.email,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'en_attente',
        // Ajouter les données complètes de l'annonce
        'announcement': announcement.toMap(),
      };
      
      print('🔍 DEBUG: Creating proposal with data: $proposalData');
      
      // Utiliser une transaction pour assurer la cohérence des données
      final batch = FirebaseFirestore.instance.batch();
      
      // Créer la proposition
      final proposalRef = FirebaseFirestore.instance.collection('proposals').doc();
      batch.set(proposalRef, proposalData);
      
      // Mettre à jour l'annonce pour ajouter l'ID de la proposition
      final announcementRef = FirebaseFirestore.instance.collection('announcements').doc(announcementId);
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
      print('🔍 DEBUG: Error sending proposal: $e');
      loading.value = false;
      Get.snackbar('Erreur', 'Erreur lors de l\'envoi : $e', backgroundColor: Get.theme.colorScheme.errorContainer);
    }
  }

  // Obtenir les propositions reçues pour les annonces de l'utilisateur connecté
  Stream<List<Proposal>> getReceivedProposalsStream() {
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 DEBUG: getReceivedProposalsStream called for user: ${user?.uid}');
    
    // Nouvelle approche plus efficace : récupérer les annonces avec leurs proposalIds
    return FirebaseFirestore.instance
        .collection('announcements')
        .where('userId', isEqualTo: user?.uid)
        .snapshots()
        .asyncMap((announcementSnapshot) async {
          if (announcementSnapshot.docs.isEmpty) {
            print('🔍 DEBUG: No announcements found for user');
            return <Proposal>[];
          }
          
          // Collecter tous les IDs de propositions de toutes les annonces
          final allProposalIds = <String>[];
          final announcementMap = <String, Announcement>{}; // Map pour associer proposalId -> announcement
          
          for (final doc in announcementSnapshot.docs) {
            final announcement = Announcement.fromMap(doc.data(), doc.id);
            for (final proposalId in announcement.proposalIds) {
              allProposalIds.add(proposalId);
              announcementMap[proposalId] = announcement;
            }
          }
          
          if (allProposalIds.isEmpty) {
            print('🔍 DEBUG: No proposal IDs found in announcements');
            return <Proposal>[];
          }
          
          print('🔍 DEBUG: Found ${allProposalIds.length} proposal IDs: $allProposalIds');
          
          // Récupérer les propositions par batches (Firestore limite à 10 éléments pour whereIn)
          final proposals = <Proposal>[];
          final batchSize = 10;
          
          for (int i = 0; i < allProposalIds.length; i += batchSize) {
            final batch = allProposalIds.skip(i).take(batchSize).toList();
            
            final batchSnapshot = await FirebaseFirestore.instance
                .collection('proposals')
                .where(FieldPath.documentId, whereIn: batch)
                .get();
            
            for (final doc in batchSnapshot.docs) {
              final proposal = Proposal.fromMap(doc.data(), doc.id);
              // Ajouter les données de l'annonce directement
              final announcement = announcementMap[doc.id];
              if (announcement != null) {
                final enrichedProposal = Proposal(
                  id: proposal.id,
                  announcementId: proposal.announcementId,
                  userId: proposal.userId,
                  userEmail: proposal.userEmail,
                  message: proposal.message,
                  createdAt: proposal.createdAt,
                  status: proposal.status,
                  announcement: announcement,
                );
                proposals.add(enrichedProposal);
              } else {
                proposals.add(proposal);
              }
            }
          }
          
          // Trier par date de création
          proposals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          print('🔍 DEBUG: Retrieved ${proposals.length} proposals');
          return proposals;
        });
  }

  // ANCIENNE MÉTHODE - gardée pour compatibilité
  Stream<List<Proposal>> getReceivedProposalsStreamOld() {
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 DEBUG: getReceivedProposalsStream called for user: ${user?.uid}');
    
    // D'abord, on récupère les annonces de l'utilisateur connecté
    return FirebaseFirestore.instance
        .collection('announcements')
        .where('userId', isEqualTo: user?.uid)
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
              .asyncMap((proposalSnapshot) async {
                print('🔍 DEBUG: Received ${proposalSnapshot.docs.length} received proposals from Firestore');
                
                final proposalsList = <Proposal>[];
                for (final doc in proposalSnapshot.docs) {
                  print('🔍 DEBUG: Processing received proposal doc: ${doc.id} with data: ${doc.data()}');
                  final proposal = Proposal.fromMap(doc.data(), doc.id);
                  final enrichedProposal = await _enrichProposalWithAnnouncement(proposal);
                  proposalsList.add(enrichedProposal);
                }
                
                print('🔍 DEBUG: Converted to ${proposalsList.length} enriched received Proposal objects');
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
      
      print('🔍 DEBUG: Proposal status updated successfully');
    } catch (e) {
      print('🔍 DEBUG: Error updating proposal status: $e');
      throw e;
    }
  }
}
