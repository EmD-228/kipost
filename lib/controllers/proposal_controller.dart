import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/proposal.dart';

class ProposalController extends GetxController {
  final RxList<Proposal> proposals = <Proposal>[].obs;
  final RxBool loading = false.obs;

  Stream<List<Proposal>> getUserProposalsStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('proposals')
        .where('userId', isEqualTo: user?.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Proposal.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendProposal({
    required String announcementId,
    required String message,
  }) async {
    loading.value = true;
    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance.collection('proposals').add({
        'announcementId': announcementId,
        'userId': user?.uid,
        'userEmail': user?.email,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'en_attente',
      });
      loading.value = false;
      Get.snackbar('Succès', 'Proposition envoyée !', backgroundColor: Get.theme.colorScheme.secondaryContainer);
    } catch (e) {
      loading.value = false;
      Get.snackbar('Erreur', 'Erreur lors de l\'envoi : $e', backgroundColor: Get.theme.colorScheme.errorContainer);
    }
  }
}
