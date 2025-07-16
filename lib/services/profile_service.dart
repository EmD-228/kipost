import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase/supabase_models.dart';
import 'supabase_service.dart';

/// Service de gestion des profils utilisateur
class ProfileService {
  final SupabaseService _supabaseService = SupabaseService();
  
  SupabaseClient get _client => _supabaseService.client;

  /// Récupère le profil d'un utilisateur par son ID
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return ProfileModel.fromMap(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  /// Récupère le profil de l'utilisateur connecté
  Future<ProfileModel?> getCurrentProfile() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return null;
    
    return await getProfile(currentUser.id);
  }

  /// Met à jour le profil utilisateur
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    Map<String, dynamic>? location,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
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
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  /// Upload et met à jour l'avatar de l'utilisateur
  Future<String> updateAvatar(File imageFile) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      // Upload de l'image
      final path = '${currentUser.id}/avatar.jpg';
      await _client.storage.from('avatars').upload(
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
      await _client.storage.from('portfolio-images').upload(
        path,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      return _client.storage.from('portfolio-images').getPublicUrl(path);
    } catch (e) {
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
      throw Exception('Erreur lors de la récupération des évaluations: $e');
    }
  }
}
