import 'package:supabase_flutter/supabase_flutter.dart';

/// Service singleton pour l'accès global au client Supabase
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  /// Initialise Supabase avec les credentials du projet
  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Accès au client Supabase
  SupabaseClient get client => _client;

  /// Raccourci pour l'utilisateur connecté
  User? get currentUser => _client.auth.currentUser;

  /// Vérifie si un utilisateur est connecté
  bool get isAuthenticated => currentUser != null;
}
