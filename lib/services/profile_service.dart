import 'dart:io';
import 'package:kipost/models/supabase/profile_model.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service de gestion des profils utilisateur
class ProfileService {
  final SupabaseService _supabaseService = SupabaseService();

  SupabaseClient get _client => _supabaseService.client;

  /// Récupère le profil d'un utilisateur par son ID
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response =
          await _client.from('profiles').select().eq('id', userId).single();

      return ProfileModel.fromMap(response);
    } on PostgrestException catch (e) {
      // Si aucun profil trouvé, retourner null au lieu de lancer une exception
      if (e.code == 'PGRST116') {
        Logger().i('Aucun profil trouvé pour l\'utilisateur $userId');
        return null;
      }
      Logger().e('Erreur PostgreSQL lors de la récupération du profil: $e');
      throw Exception('Erreur lors de la récupération du profil: ${e.message}');
    } catch (e) {
      Logger().e('Erreur lors de la récupération du profil: $e');
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  /// Récupère le profil de l'utilisateur connecté
  Future<ProfileModel?> getCurrentProfile() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return null;

    return await getProfile(currentUser.id);
  }

  /// Crée un profil initial pour un nouvel utilisateur
  Future<ProfileModel> createInitialProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Vérifier d'abord si le profil existe déjà
      final existingProfile = await getProfile(userId);
      if (existingProfile != null) {
        Logger().i('Profil existant trouvé pour l\'utilisateur $userId');
        return existingProfile;
      }

      // Créer un nouveau profil s'il n'existe pas
      final profileData = {
        'id': userId,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'is_verified': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('profiles')
          .insert(profileData)
          .select()
          .single();

      Logger().i('Nouveau profil créé pour l\'utilisateur $userId');
      return ProfileModel.fromMap(response);
    } on PostgrestException catch (e) {
      // Si c'est une erreur de clé dupliquée, récupérer le profil existant
      if (e.code == '23505') {
        Logger().i('Profil déjà existant détecté, récupération...');
        final existingProfile = await getProfile(userId);
        if (existingProfile != null) {
          return existingProfile;
        }
      }
      Logger().e('Erreur PostgreSQL lors de la création du profil: $e');
      throw Exception('Erreur lors de la création du profil: ${e.message}');
    } catch (e) {
      Logger().e('Erreur lors de la création du profil: $e');
      throw Exception('Erreur lors de la création du profil: $e');
    }
  }

  /// Met à jour le profil utilisateur
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    Map<String, dynamic>? location,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      Logger().e('Utilisateur non connecté');
      throw Exception('Utilisateur non connecté');
    }

    try {
      final updateData = <String, dynamic>{};

      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (location != null) updateData['location'] = location;

      if (updateData.isNotEmpty) {
        await _client
            .from('profiles')
            .update(updateData)
            .eq('id', currentUser.id);
      }
    } catch (e) {
      Logger().e('Erreur lors de la mise à jour du profil: $e');
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  /// Upload et met à jour l'avatar de l'utilisateur
  Future<String> updateAvatar(File imageFile) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      Logger().e('Utilisateur non connecté');
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Upload de l'image
      final path = '${currentUser.id}/avatar.jpg';
      await _client.storage
          .from('avatars')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // Récupération de l'URL publique
      final imageUrl = _client.storage.from('avatars').getPublicUrl(path);

      // Mise à jour du profil avec la nouvelle URL
      await _client
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', currentUser.id);

      return imageUrl;
    } catch (e) {
      Logger().e('Erreur lors de la mise à jour de l\'avatar: $e');
      throw Exception('Erreur lors de la mise à jour de l\'avatar: $e');
    }
  }

  /// Upload d'images pour le portfolio (prestataires)
  Future<String> uploadPortfolioImage(File imageFile, String fileName) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final path = '${currentUser.id}/portfolio/$fileName';
      await _client.storage
          .from('portfolio-images')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      return _client.storage.from('portfolio-images').getPublicUrl(path);
    } catch (e) {
      Logger().e('Erreur lors de l\'upload de l\'image: $e');
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Marque un profil comme vérifié (admin seulement)
  Future<void> verifyProfile(String userId) async {
    try {
      await _client
          .from('profiles')
          .update({'is_verified': true})
          .eq('id', userId);
    } catch (e) {
      Logger().e('Erreur lors de la vérification du profil: $e');
      throw Exception('Erreur lors de la vérification du profil: $e');
    }
  }

  /// Récupère les évaluations d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserReviews(String userId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('*, reviewer:profiles!reviewer_id(*)')
          .eq('reviewee_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Logger().e('Erreur lors de la récupération des évaluations: $e');

      throw Exception('Erreur lors de la récupération des évaluations: $e');
    }
  }
}
