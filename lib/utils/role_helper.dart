import 'package:kipost/models/user.dart';

class RoleHelper {
  static const String CLIENT_ROLE = 'client';
  static const String PROVIDER_ROLE = 'provider';
  
  /// Vérifie si l'utilisateur peut créer des annonces
  static bool canCreateAnnouncements(UserModel? user) {
    return user?.canCreateAnnouncements ?? false;
  }
  
  /// Vérifie si l'utilisateur peut répondre aux annonces
  static bool canSubmitProposals(UserModel? user) {
    return user?.canSubmitProposals ?? false;
  }
  
  /// Vérifie si l'utilisateur a les deux rôles
  static bool hasBothRoles(UserModel? user) {
    return user?.hasBothRoles ?? false;
  }
  
  /// Retourne la liste des rôles actifs de l'utilisateur
  static List<String> getActiveRoles(UserModel? user) {
    if (user == null) return [];
    
    List<String> roles = [];
    if (user.isClient) roles.add('Client');
    if (user.isProvider) roles.add('Prestataire');
    return roles;
  }
  
  /// Retourne une description textuelle des rôles
  static String getRoleDescription(UserModel? user) {
    if (user == null) return 'Aucun rôle';
    
    final roles = getActiveRoles(user);
    if (roles.isEmpty) return 'Aucun rôle';
    if (roles.length == 1) return roles.first;
    return roles.join(' & ');
  }
  
  /// Retourne la couleur principale basée sur les rôles
  static Map<String, dynamic> getPrimaryRoleColors(UserModel? user) {
    if (user == null || (!user.isClient && !user.isProvider)) {
      return {'background': '#F3F4F6', 'text': '#6B7280'}; // Gris
    }
    
    if (user.hasBothRoles) {
      return {'background': '#EDE9FE', 'text': '#7C3AED'}; // Violet pour les deux rôles
    }
    
    if (user.isProvider) {
      return {'background': '#DCFCE7', 'text': '#16A34A'}; // Vert pour prestataire
    }
    
    return {'background': '#DBEAFE', 'text': '#2563EB'}; // Bleu pour client
  }
}
