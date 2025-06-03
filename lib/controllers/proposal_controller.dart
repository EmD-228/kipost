import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/proposal.dart';

class ProposalController extends GetxController {
  final RxList<Proposal> proposals = <Proposal>[].obs;
  final RxBool loading = false.obs;

  Stream<List<Proposal>> getUserProposalsStream() {
    final user = FirebaseAuth.instance.currentUser;
    print('🔍 DEBUG: getUserProposalsStream called for user: ${user?.uid}');
    
    return FirebaseFirestore.instance
        .collection('proposals')
        .where('userId', isEqualTo: user?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🔍 DEBUG: Received ${snapshot.docs.length} proposals from Firestore');
          final proposalsList = snapshot.docs
              .map((doc) {
                print('🔍 DEBUG: Processing proposal doc: ${doc.id} with data: ${doc.data()}');
                return Proposal.fromMap(doc.data(), doc.id);
              })
              .toList();
          print('🔍 DEBUG: Converted to ${proposalsList.length} Proposal objects');
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
      
      final docRef = await FirebaseFirestore.instance.collection('proposals').add(proposalData);
      print('🔍 DEBUG: Proposal created successfully with ID: ${docRef.id}');
      
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
              .map((proposalSnapshot) {
                print('🔍 DEBUG: Received ${proposalSnapshot.docs.length} received proposals from Firestore');
                final proposalsList = proposalSnapshot.docs
                    .map((doc) {
                      print('🔍 DEBUG: Processing received proposal doc: ${doc.id} with data: ${doc.data()}');
                      return Proposal.fromMap(doc.data(), doc.id);
                    })
                    .toList();
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
      
      print('🔍 DEBUG: Proposal status updated successfully');
    } catch (e) {
      print('🔍 DEBUG: Error updating proposal status: $e');
      throw e;
    }
  }
}
