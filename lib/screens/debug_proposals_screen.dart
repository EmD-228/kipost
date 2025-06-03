import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DebugProposalsScreen extends StatelessWidget {
  const DebugProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Propositions'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await _debugFirestore();
            },
            child: const Text('Debug Firestore'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _createTestProposal();
            },
            child: const Text('Créer proposition test'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('proposals')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text('ID: ${doc.id}'),
                      subtitle: Text('Data: $data'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _debugFirestore() async {
    print('🔍 === DEBUG FIRESTORE ===');
    
    final currentUser = FirebaseAuth.instance.currentUser;
    print('🔍 Current user: ${currentUser?.uid} (${currentUser?.email})');
    
    // Récupérer toutes les propositions
    final allProposals = await FirebaseFirestore.instance
        .collection('proposals')
        .get();
    print('🔍 Total proposals in database: ${allProposals.docs.length}');
    
    for (var doc in allProposals.docs) {
      print('🔍 Proposal ${doc.id}: ${doc.data()}');
    }
    
    // Récupérer les propositions de l'utilisateur actuel
    if (currentUser != null) {
      final userProposals = await FirebaseFirestore.instance
          .collection('proposals')
          .where('userId', isEqualTo: currentUser.uid)
          .get();
      print('🔍 User proposals: ${userProposals.docs.length}');
      
      for (var doc in userProposals.docs) {
        print('🔍 User proposal ${doc.id}: ${doc.data()}');
      }
    }
    
    print('🔍 === END DEBUG ===');
  }

  Future<void> _createTestProposal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('🔍 No user logged in');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('proposals').add({
        'announcementId': 'test-announcement-id',
        'userId': user.uid,
        'userEmail': user.email,
        'message': 'Test proposal message',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'en_attente',
      });
      print('🔍 Test proposal created successfully');
      Get.snackbar('Succès', 'Proposition test créée !');
    } catch (e) {
      print('🔍 Error creating test proposal: $e');
      Get.snackbar('Erreur', 'Erreur: $e');
    }
  }
}
