import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kipost/models/announcement.dart';
import 'package:kipost/models/category.dart';
import 'package:kipost/models/urgency_level.dart';
import 'package:kipost/models/user.dart';

class AnnouncementController extends GetxController {
  final RxBool loading = false.obs;
  final RxList<Announcement> announcements = <Announcement>[].obs;
  final RxBool fetchingUserData = false.obs;

  // ========== CRUD Operations ==========

  /// Créer une nouvelle annonce avec les modèles structurés
  Future<void> createAnnouncement({
    required String title,
    required String description,
    required String categoryId,
    required String urgencyLevelId,
    required String location,
    double? price,
  }) async {
    loading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Validation des modèles
      final category = Category.getCategoryById(categoryId);
      final urgencyLevel = UrgencyLevel.getUrgencyById(urgencyLevelId);
      
      if (category == null) {
        throw Exception('Catégorie invalide');
      }
      if (urgencyLevel == null) {
        throw Exception('Niveau d\'urgence invalide');
      }

      // Créer l'annonce dans Firestore
      await FirebaseFirestore.instance.collection('annonces').add(
       

        {
        'title': title,
        'description': description,
        'category': category.toMap(),
        'urgencyLevel': urgencyLevel.toMap(),
        'location': location,
        'price': price,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'open',
        'creatorId': user.uid,
        'creatorEmail': user.email,
        'creatorProfile':user.photoURL,
        'proposalIds': [],
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

  /// Mettre à jour une annonce existante
  Future<void> updateAnnouncement({
    required String announcementId,
    String? title,
    String? description,
    String? categoryId,
    String? urgencyLevelId,
    String? location,
    double? price,
    String? status,
  }) async {
    loading.value = true;
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (categoryId != null) {
        final category = Category.getCategoryById(categoryId);
        if (category == null) throw Exception('Catégorie invalide');
        updateData['category'] = category;
      }
      if (urgencyLevelId != null) {
        final urgencyLevel = UrgencyLevel.getUrgencyById(urgencyLevelId);
        if (urgencyLevel == null) throw Exception('Niveau d\'urgence invalide');
        updateData['urgencyLevel'] = urgencyLevel;
      }
      if (location != null) updateData['location'] = location;
      if (price != null) updateData['price'] = price;
      if (status != null) updateData['status'] = status;

      await FirebaseFirestore.instance
          .collection('annonces')
          .doc(announcementId)
          .update(updateData);

      loading.value = false;
      Get.snackbar(
        'Succès',
        'Annonce mise à jour avec succès !',
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

  /// Supprimer une annonce
  Future<void> deleteAnnouncement(String id) async {
    loading.value = true;
    try {
      // Supprimer d'abord toutes les propositions liées
      final proposals = await FirebaseFirestore.instance
          .collection('proposals')
          .where('announcementId', isEqualTo: id)
          .get();
      
      final batch = FirebaseFirestore.instance.batch();
      
      // Supprimer les propositions
      for (var doc in proposals.docs) {
        batch.delete(doc.reference);
      }
      
      // Supprimer l'annonce
      batch.delete(FirebaseFirestore.instance.collection('annonces').doc(id));
      
      await batch.commit();
      
      loading.value = false;
      Get.snackbar(
        'Succès',
        'Annonce supprimée avec succès',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );
    } catch (e) {
      loading.value = false;
      Get.snackbar(
        'Erreur',
        'Erreur lors de la suppression : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    }
  }

  // ========== Récupération des données ==========
  /// Stream de toutes les annonces avec données enrichies
  Stream<List<Announcement>> getAnnouncementsStream({
    String? categoryId,
    String? urgencyLevelId,
    String? status,
    String? searchQuery,
  }) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('annonces')
        .orderBy('createdAt', descending: true);

    // Filtres optionnels
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('category', isEqualTo: Category.getCategoryById(categoryId));
    }
    if (urgencyLevelId != null && urgencyLevelId.isNotEmpty) {
      query = query.where('urgencyLevel', isEqualTo: UrgencyLevel.getUrgencyById(urgencyLevelId));
    }
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().asyncMap((snapshot) async {
      final announcements = <Announcement>[];
      
      for (var doc in snapshot.docs) {
        try {
          final announcement = await _buildAnnouncementWithProfile(doc.data(), doc.id);
          
          // Filtre de recherche textuelle
          if (searchQuery != null && searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            if (!announcement.title.toLowerCase().contains(query) &&
                !announcement.description.toLowerCase().contains(query) &&
                !announcement.category.name.toLowerCase().contains(query) &&
                !announcement.location.toLowerCase().contains(query)) {
              continue;
            }
          }
          
          announcements.add(announcement);
        } catch (e) {
          printInfo(info:'Erreur lors de la construction de l\'annonce ${doc.data()}: $e');
        }
      }
      
      return announcements;
    });
  }

  /// Récupérer une annonce par ID avec profil du créateur
  Future<Announcement?> getAnnouncementById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('annonces')
          .doc(id)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return await _buildAnnouncementWithProfile(doc.data()!, doc.id);
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

  /// Stream des annonces d'un utilisateur spécifique
  Stream<List<Announcement>> getUserAnnouncementsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('annonces')
        .where('creatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final announcements = <Announcement>[];
      
      for (var doc in snapshot.docs) {
        try {
          final announcement = await _buildAnnouncementWithProfile(doc.data(), doc.id);
          announcements.add(announcement);
        } catch (e) {
          print('Erreur lors de la construction de l\'annonce ${doc.id}: $e');
        }
      }
      
      return announcements;
    });
  }

  /// Construire une annonce avec le profil du créateur
  Future<Announcement> _buildAnnouncementWithProfile(
    Map<String, dynamic> data, 
    String docId
  ) async {
    UserModel? creatorProfile;
    
    try {
      final creatorId = data['creatorId'] as String?;
      if (creatorId != null && creatorId.isNotEmpty) {
        creatorProfile = await _getUserProfile(creatorId);
      }
    } catch (e) {
      print('Erreur lors de la récupération du profil créateur: $e');
    }

    // Créer l'annonce de base
    final announcement = Announcement.fromMap(data, docId);
    
    // Retourner avec le profil enrichi
    return announcement.copyWith(creatorProfile: creatorProfile);
  }

  /// Récupérer le profil d'un utilisateur
  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists && userDoc.data() != null) {
        return UserModel.fromMap(userDoc.data()!, userDoc.id);
      }
    } catch (e) {
      print('Erreur lors de la récupération du profil utilisateur $userId: $e');
    }
    return null;
  }

  // ========== Gestion des propositions ==========

  /// Ajouter une proposition à une annonce
  Future<void> addProposalToAnnouncement(String announcementId, String proposalId) async {
    try {
      await FirebaseFirestore.instance
          .collection('annonces')
          .doc(announcementId)
          .update({
        'proposalIds': FieldValue.arrayUnion([proposalId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de la proposition: $e');
      throw e;
    }
  }

  /// Retirer une proposition d'une annonce
  Future<void> removeProposalFromAnnouncement(String announcementId, String proposalId) async {
    try {
      await FirebaseFirestore.instance
          .collection('annonces')
          .doc(announcementId)
          .update({
        'proposalIds': FieldValue.arrayRemove([proposalId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la suppression de la proposition: $e');
      throw e;
    }
  }

  /// Sélectionner un prestataire pour une annonce
  Future<void> selectServiceProvider(
    String announcementId, 
    String selectedProposalId, 
    String selectedUserId
  ) async {
    loading.value = true;
    try {
      // Mettre à jour l'annonce avec le prestataire sélectionné
      await FirebaseFirestore.instance
          .collection('annonces')
          .doc(announcementId)
          .update({
        'status': 'assigned',
        'selectedProviderId': selectedUserId,
        'selectedProposalId': selectedProposalId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour la proposition sélectionnée
      await FirebaseFirestore.instance
          .collection('proposals')
          .doc(selectedProposalId)
          .update({
        'status': 'acceptée',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Rejeter toutes les autres propositions
      final otherProposals = await FirebaseFirestore.instance
          .collection('proposals')
          .where('announcementId', isEqualTo: announcementId)
          .where('status', isEqualTo: 'en_attente')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in otherProposals.docs) {
        if (doc.id != selectedProposalId) {
          batch.update(doc.reference, {
            'status': 'refusée',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();

      loading.value = false;
      Get.snackbar(
        'Succès', 
        'Prestataire sélectionné avec succès !',
        backgroundColor: Colors.green.shade100, 
        colorText: Colors.black
      );
    } catch (e) {
      loading.value = false;
      Get.snackbar(
        'Erreur', 
        'Erreur lors de la sélection : $e',
        backgroundColor: Colors.red.shade100, 
        colorText: Colors.black
      );
    }
  }

  /// Stream des propositions pour une annonce
  Stream<List<Map<String, dynamic>>> getAnnouncementProposalsStream(String announcementId) {
    return FirebaseFirestore.instance
        .collection('proposals')
        .where('announcementId', isEqualTo: announcementId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  // ========== Méthodes utilitaires ==========

  /// Fermer une annonce
  Future<void> closeAnnouncement(String announcementId) async {
    await updateAnnouncement(
      announcementId: announcementId,
      status: 'closed',
    );
  }

  /// Rouvrir une annonce
  Future<void> reopenAnnouncement(String announcementId) async {
    await updateAnnouncement(
      announcementId: announcementId,
      status: 'open',
    );
  }

  /// Vérifier si l'utilisateur actuel est le créateur de l'annonce
  bool isCurrentUserOwner(Announcement announcement) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && currentUser.uid == announcement.creatorId;
  }

  /// Obtenir les statistiques d'une annonce
  Future<Map<String, int>> getAnnouncementStats(String announcementId) async {
    try {
      final proposalsSnapshot = await FirebaseFirestore.instance
          .collection('proposals')
          .where('announcementId', isEqualTo: announcementId)
          .get();

      final proposals = proposalsSnapshot.docs;
      final totalProposals = proposals.length;
      final acceptedProposals = proposals.where((doc) => 
          doc.data()['status'] == 'acceptée').length;
      final pendingProposals = proposals.where((doc) => 
          doc.data()['status'] == 'en_attente').length;
      final rejectedProposals = proposals.where((doc) => 
          doc.data()['status'] == 'refusée').length;

      return {
        'total': totalProposals,
        'accepted': acceptedProposals,
        'pending': pendingProposals,
        'rejected': rejectedProposals,
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {
        'total': 0,
        'accepted': 0,
        'pending': 0,
        'rejected': 0,
      };
    }
  }

  /// Migration: S'assurer que toutes les annonces ont le champ proposalIds
  Future<void> ensureProposalIdsField() async {
    loading.value = true;
    try {
      final announcements = await FirebaseFirestore.instance
          .collection('annonces')
          .get();
      
      final batch = FirebaseFirestore.instance.batch();
      int updatedCount = 0;
      
      for (final doc in announcements.docs) {
        final data = doc.data();
        if (!data.containsKey('proposalIds')) {
          batch.update(doc.reference, {
            'proposalIds': [],
            'updatedAt': FieldValue.serverTimestamp(),
          });
          updatedCount++;
        }
      }
      
      if (updatedCount > 0) {
        await batch.commit();
        print('Updated $updatedCount announcements with proposalIds field');
        Get.snackbar(
          'Migration',
          'Mis à jour $updatedCount annonces avec le champ proposalIds',
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.black,
        );
      } else {
        print('All announcements already have proposalIds field');
      }
    } catch (e) {
      print('Error ensuring proposalIds field: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la vérification : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } finally {
      loading.value = false;
    }
  }

  /// Migration: Migrer les anciennes annonces vers la nouvelle structure
  Future<void> migrateOldAnnouncements() async {
    loading.value = true;
    try {
      final announcements = await FirebaseFirestore.instance
          .collection('annonces')
          .get();
      
      final batch = FirebaseFirestore.instance.batch();
      int migratedCount = 0;
      
      for (final doc in announcements.docs) {
        final data = doc.data();
        final updateData = <String, dynamic>{};
        bool needsUpdate = false;
        
        // Migrer category si c'est une string vers categoryId
        if (data['category'] is String && data['category'] != null) {
          final categoryString = data['category'] as String;
          final category = Category.getDefaultCategories()
              .firstWhere((cat) => cat.name.toLowerCase() == categoryString.toLowerCase(),
                  orElse: () => Category.getCategoryById('autre')!);
          updateData['category'] = category.id;
          needsUpdate = true;
        }
        
        // Migrer urgencyLevel si nécessaire
        if (data['urgencyLevel'] == null || data['urgencyLevel'] == '') {
          updateData['urgencyLevel'] = 'modere';
          needsUpdate = true;
        }
        
        // Ajouter proposalIds si manquant
        if (!data.containsKey('proposalIds')) {
          updateData['proposalIds'] = [];
          needsUpdate = true;
        }
        
        // Migrer budget vers price si nécessaire
        if (data.containsKey('budget') && !data.containsKey('price')) {
          final budget = data['budget'];
          if (budget != null) {
            final price = double.tryParse(budget.toString());
            if (price != null) {
              updateData['price'] = price;
            }
          }
          needsUpdate = true;
        }
        
        if (needsUpdate) {
          updateData['updatedAt'] = FieldValue.serverTimestamp();
          batch.update(doc.reference, updateData);
          migratedCount++;
        }
      }
      
      if (migratedCount > 0) {
        await batch.commit();
        print('Migrated $migratedCount announcements to new structure');
        Get.snackbar(
          'Migration',
          'Migré $migratedCount annonces vers la nouvelle structure',
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.black,
        );
      } else {
        print('All announcements are already up to date');
      }
    } catch (e) {
      print('Error migrating announcements: $e');
      Get.snackbar(
        'Erreur',
        'Erreur lors de la migration : $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } finally {
      loading.value = false;
    }
  }

  // ========== Méthodes de recherche et filtrage ==========

  /// Rechercher des annonces par texte
  Future<List<Announcement>> searchAnnouncements(String query) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('annonces')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final announcements = <Announcement>[];
      final queryLower = query.toLowerCase();

      for (var doc in snapshot.docs) {
        final announcement = await _buildAnnouncementWithProfile(doc.data(), doc.id);
        
        if (announcement.title.toLowerCase().contains(queryLower) ||
            announcement.description.toLowerCase().contains(queryLower) ||
            announcement.category.name.toLowerCase().contains(queryLower) ||
            announcement.location.toLowerCase().contains(queryLower)) {
          announcements.add(announcement);
        }
      }

      return announcements;
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return [];
    }
  }

  /// Obtenir les annonces par catégorie
  Stream<List<Announcement>> getAnnouncementsByCategory(String categoryId) {
    return getAnnouncementsStream(categoryId: categoryId);
  }

  /// Obtenir les annonces par niveau d'urgence
  Stream<List<Announcement>> getAnnouncementsByUrgency(String urgencyLevelId) {
    return getAnnouncementsStream(urgencyLevelId: urgencyLevelId);
  }

  /// Obtenir les annonces récentes (dernières 24h)
  Stream<List<Announcement>> getRecentAnnouncements() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    
    return FirebaseFirestore.instance
        .collection('annonces')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final announcements = <Announcement>[];
      
      for (var doc in snapshot.docs) {
        try {
          final announcement = await _buildAnnouncementWithProfile(doc.data(), doc.id);
          announcements.add(announcement);
        } catch (e) {
          print('Erreur lors de la construction de l\'annonce ${doc.id}: $e');
        }
      }
      
      return announcements;
    });
  }

  @override
  void onClose() {
    // Nettoyer les ressources si nécessaire
    super.onClose();
  }
}
