import 'package:cloud_firestore/cloud_firestore.dart';

/// Script de migration pour ajouter les proposalIds aux annonces existantes
/// À exécuter une seule fois pour migrer les données existantes
class ProposalMigration {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migre toutes les propositions existantes vers le nouveau système
  static Future<void> migrateExistingProposals() async {
    print('🔄 Début de la migration des propositions...');
    
    try {
      // 1. Récupérer toutes les propositions existantes
      final proposalsSnapshot = await _firestore.collection('proposals').get();
      
      if (proposalsSnapshot.docs.isEmpty) {
        print('✅ Aucune proposition à migrer');
        return;
      }
      
      print('📝 ${proposalsSnapshot.docs.length} propositions trouvées');
      
      // 2. Grouper les propositions par announcementId
      final Map<String, List<String>> announcementProposals = {};
      
      for (final proposalDoc in proposalsSnapshot.docs) {
        final data = proposalDoc.data();
        final announcementId = data['announcementId'] as String?;
        
        if (announcementId != null) {
          announcementProposals.putIfAbsent(announcementId, () => []);
          announcementProposals[announcementId]!.add(proposalDoc.id);
        }
      }
      
      print('🎯 ${announcementProposals.length} annonces ont des propositions');
      
      // 3. Mettre à jour les annonces avec leurs proposalIds
      final batch = _firestore.batch();
      int updateCount = 0;
      
      for (final entry in announcementProposals.entries) {
        final announcementId = entry.key;
        final proposalIds = entry.value;
        
        // Vérifier que l'annonce existe encore
        final announcementRef = _firestore.collection('announcements').doc(announcementId);
        final announcementDoc = await announcementRef.get();
        
        if (announcementDoc.exists) {
          final currentData = announcementDoc.data()!;
          final existingProposalIds = List<String>.from(currentData['proposalIds'] ?? []);
          
          // Fusionner les IDs existants avec les nouveaux (éviter les doublons)
          final allProposalIds = {...existingProposalIds, ...proposalIds}.toList();
          
          batch.update(announcementRef, {
            'proposalIds': allProposalIds,
            'migratedAt': FieldValue.serverTimestamp(),
          });
          
          updateCount++;
          print('📝 Annonce $announcementId: ${allProposalIds.length} propositions');
          
          // Limiter la taille des batches (Firestore limite à 500 opérations par batch)
          if (updateCount % 450 == 0) {
            await batch.commit();
            print('💾 Batch de $updateCount annonces sauvegardé');
          }
        } else {
          print('⚠️  Annonce $announcementId non trouvee (propositions orphelines: ${proposalIds.length})');
        }
      }
      
      // Sauvegarder le dernier batch
      if (updateCount % 450 != 0) {
        await batch.commit();
      }
      
      print('✅ Migration terminée: $updateCount annonces mises à jour');
      
    } catch (e) {
      print('❌ Erreur lors de la migration: $e');
      rethrow;
    }
  }
  
  /// Vérifie l'état de la migration
  static Future<void> checkMigrationStatus() async {
    print('🔍 Verification de l\'etat de la migration...');
    
    try {
      // Compter les propositions totales
      final proposalsSnapshot = await _firestore.collection('proposals').get();
      final totalProposals = proposalsSnapshot.docs.length;
      
      // Compter les annonces avec proposalIds
      final announcementsSnapshot = await _firestore
          .collection('announcements')
          .where('proposalIds', isNotEqualTo: [])
          .get();
      
      final announcementsWithProposals = announcementsSnapshot.docs.length;
      
      // Compter le total des proposalIds dans les annonces
      int totalProposalIdsInAnnouncements = 0;
      for (final doc in announcementsSnapshot.docs) {
        final proposalIds = List<String>.from(doc.data()['proposalIds'] ?? []);
        totalProposalIdsInAnnouncements += proposalIds.length;
      }
      
      print('📊 Etat de la migration:');
      print('   - Propositions totales: $totalProposals');
      print('   - Annonces avec propositions: $announcementsWithProposals');
      print('   - Total proposalIds dans annonces: $totalProposalIdsInAnnouncements');
      
      if (totalProposals == totalProposalIdsInAnnouncements) {
        print('✅ Migration complete: tous les proposalIds sont references');
      } else {
        print('⚠️  Migration incomplete: ${totalProposals - totalProposalIdsInAnnouncements} propositions non referencees');
      }
      
    } catch (e) {
      print('❌ Erreur lors de la verification: $e');
    }
  }
  
  /// Nettoie les proposalIds orphelins (qui pointent vers des propositions supprimées)
  static Future<void> cleanupOrphanedProposalIds() async {
    print('🧹 Nettoyage des proposalIds orphelins...');
    
    try {
      final announcementsSnapshot = await _firestore
          .collection('announcements')
          .where('proposalIds', isNotEqualTo: [])
          .get();
      
      final batch = _firestore.batch();
      int cleanupCount = 0;
      
      for (final announcementDoc in announcementsSnapshot.docs) {
        final data = announcementDoc.data();
        final proposalIds = List<String>.from(data['proposalIds'] ?? []);
        
        // Vérifier quels proposalIds existent encore
        final validProposalIds = <String>[];
        
        for (final proposalId in proposalIds) {
          final proposalDoc = await _firestore.collection('proposals').doc(proposalId).get();
          if (proposalDoc.exists) {
            validProposalIds.add(proposalId);
          }
        }
        
        // Mettre à jour si des proposalIds ont été supprimés
        if (validProposalIds.length != proposalIds.length) {
          batch.update(announcementDoc.reference, {
            'proposalIds': validProposalIds,
            'cleanedAt': FieldValue.serverTimestamp(),
          });
          
          cleanupCount++;
          print('🧹 Annonce ${announcementDoc.id}: ${proposalIds.length} → ${validProposalIds.length} propositions');
        }
      }
      
      if (cleanupCount > 0) {
        await batch.commit();
        print('✅ Nettoyage termine: $cleanupCount annonces nettoyees');
      } else {
        print('✅ Aucun nettoyage necessaire');
      }
      
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }
}
