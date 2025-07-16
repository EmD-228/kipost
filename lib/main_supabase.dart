import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'config/supabase_config.dart';
import 'services/supabase_service.dart';
import 'app_route.dart';

/// Point d'entrée principal avec Supabase
/// Ce fichier montre comment initialiser Supabase selon FRONTEND_BACKEND_INTERACTION.md
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Supabase selon la documentation
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialisation du service Supabase
  await SupabaseService().initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const KipostSupabaseApp());
}

/// Application principale avec Supabase
class KipostSupabaseApp extends StatelessWidget {
  const KipostSupabaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kipost - Services Locaux',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/splash',
      getPages: AppRoutes.routes,
    );
  }
}

/// Helper pour un accès facile au client Supabase dans toute l'application
/// Selon la documentation FRONTEND_BACKEND_INTERACTION.md
final supabase = Supabase.instance.client;
