#!/usr/bin/env dart

/// Script standalone pour migrer les propositions existantes
/// Usage: dart migrate_database.dart
/// 
/// Ce script doit être exécuté depuis le répertoire racine du projet Flutter

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  print('🚀 Script de migration de la base de données Kipost');
  print('==========================================');
  
  try {
    // Initialiser Firebase
    print('🔄 Initialisation de Firebase...');
    await Firebase.initializeApp();
    print('✅ Firebase initialisé');
    
    // Afficher le menu
    await showMenu();
    
  } catch (e) {
    print('❌ Erreur d\'initialisation Firebase: $e');
    exit(1);
  }
}

Future<void> showMenu() async {
  while (true) {
    print('\n📋 Options disponibles:');
    print('1. Vérifier l\'état de la migration');
    print('2. Exécuter la migration complète');
    print('3. Nettoyer les proposalIds orphelins');
    print('4. Quitter');
    print('\nChoisissez une option (1-4): ');
    
    final input = stdin.readLineSync();
    
    switch (input) {
      case '1':
        await checkMigrationStatus();
        break;
      case '2':
        await runMigration();
        break;
      case '3':
        await cleanupOrphans();
        break;
      case '4':
        print('👋 Au revoir !');
        exit(0);
      default:
        print('❌ Option invalide. Veuillez choisir 1, 2, 3 ou 4.');
    }
  }
}

Future<void> checkMigrationStatus() async {
  print('\n🔍 Vérification de l\'état de la migration...');
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Compter les propositions totales
    final proposalsSnapshot = await firestore.collection('proposals').get();
    final totalProposals = proposalsSnapshot.docs.length;
    
    // Compter les annonces avec proposalIds
    final announcementsSnapshot = await firestore
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
    
    print('\n📊 État actuel de la base de données:');
    print('   🔢 Propositions totales: $totalProposals');
    print('   📝 Annonces avec propositions: $announcementsWithProposals');
    print('   🔗 Total proposalIds dans annonces: $totalProposalIdsInAnnouncements');
    
    if (totalProposals == totalProposalIdsInAnnouncements) {
      print('   ✅ Migration complète: tous les proposalIds sont référencés');
    } else {
      final missing = totalProposals - totalProposalIdsInAnnouncements;
      print('   ⚠️  Migration incomplète: $missing propositions non référencées');
    }
    
    // Vérifier s'il y a des propositions sans annonce correspondante
    int orphanedProposals = 0;
    for (final proposalDoc in proposalsSnapshot.docs) {
      final data = proposalDoc.data();
      final announcementId = data['announcementId'] as String?;
      if (announcementId != null) {
        final announcementDoc = await firestore.collection('announcements').doc(announcementId).get();
        if (!announcementDoc.exists) {
          orphanedProposals++;
        }
      }
    }
    
    if (orphanedProposals > 0) {
      print('   ⚠️  $orphanedProposals propositions orphelines (annonce supprimée)');
    }
    
  } catch (e) {
    print('❌ Erreur lors de la vérification: $e');
  }
}

Future<void> runMigration() async {
  print('\n🔄 Démarrage de la migration...');
  print('⚠️  Cette opération va modifier la base de données.');
  print('Êtes-vous sûr de vouloir continuer ? (y/N): ');
  
  final confirmation = stdin.readLineSync()?.toLowerCase();
  if (confirmation != 'y' && confirmation != 'yes') {
    print('❌ Migration annulée.');
    return;
  }
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    // 1. Récupérer toutes les propositions existantes
    print('📖 Récupération des propositions...');
    final proposalsSnapshot = await firestore.collection('proposals').get();
    
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
    final batch = firestore.batch();
    int updateCount = 0;
    
    for (final entry in announcementProposals.entries) {
      final announcementId = entry.key;
      final proposalIds = entry.value;
      
      // Vérifier que l'annonce existe encore
      final announcementRef = firestore.collection('announcements').doc(announcementId);
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
        
        // Limiter la taille des batches
        if (updateCount % 450 == 0) {
          await batch.commit();
          print('💾 Batch de $updateCount annonces sauvegardé');
        }
      } else {
        print('⚠️  Annonce $announcementId non trouvée (propositions orphelines: ${proposalIds.length})');
      }
    }
    
    // Sauvegarder le dernier batch
    if (updateCount % 450 != 0) {
      await batch.commit();
    }
    
    print('✅ Migration terminée: $updateCount annonces mises à jour');
    
  } catch (e) {
    print('❌ Erreur lors de la migration: $e');
  }
}

Future<void> cleanupOrphans() async {
  print('\n🧹 Nettoyage des proposalIds orphelins...');
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    final announcementsSnapshot = await firestore
        .collection('announcements')
        .where('proposalIds', isNotEqualTo: [])
        .get();
    
    final batch = firestore.batch();
    int cleanupCount = 0;
    
    for (final announcementDoc in announcementsSnapshot.docs) {
      final data = announcementDoc.data();
      final proposalIds = List<String>.from(data['proposalIds'] ?? []);
      
      // Vérifier quels proposalIds existent encore
      final validProposalIds = <String>[];
      
      for (final proposalId in proposalIds) {
        final proposalDoc = await firestore.collection('proposals').doc(proposalId).get();
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
      print('✅ Nettoyage terminé: $cleanupCount annonces nettoyées');
    } else {
      print('✅ Aucun nettoyage nécessaire');
    }
    
  } catch (e) {
    print('❌ Erreur lors du nettoyage: $e');
  }
}
