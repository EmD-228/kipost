import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'package:logger/logger.dart';


/// Service d'authentification pour Kipost
class AuthService {
  final SupabaseService _supabaseService = SupabaseService();
  
  SupabaseClient get _client => _supabaseService.client;

  /// Inscription d'un nouvel utilisateur
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );
      return response;
    } catch (e) {
      Logger().e('Erreur lors de l\'inscription: $e');
      
       throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  /// Connexion d'un utilisateur existant
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
       Logger().e('Erreur lors de l\'inscription: $e'); 
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  /// Déconnexion de l'utilisateur
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      Logger().e('Erreur lors de la déconnexion: $e');
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      Logger().e('Erreur lors de la réinitialisation: $e');
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }

  /// Stream des changements d'état d'authentification
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Utilisateur connecté
  User? get currentUser => _client.auth.currentUser;

  /// Vérifie si un utilisateur est connecté
  bool get isAuthenticated => currentUser != null;
}
