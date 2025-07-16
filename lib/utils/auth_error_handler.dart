/// Gestionnaire centralisé des erreurs d'authentification Supabase
/// Utilisé pour standardiser les messages d'erreur sur les écrans d'auth
class AuthErrorHandler {
  /// Convertit une exception d'authentification en message d'erreur utilisateur
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Erreurs de mot de passe
    if (errorString.contains('weak_password') ||
        errorString.contains('weak-password')) {
      return 'Le mot de passe est trop faible (minimum 6 caractères)';
    }

    // Erreurs d'email déjà utilisé
    if (errorString.contains('email_address_taken') ||
        errorString.contains('email-already-in-use') ||
        errorString.contains('user already registered')) {
      return 'Cet email est déjà utilisé';
    }

    // Erreurs d'email invalide
    if (errorString.contains('invalid_email') ||
        errorString.contains('email_address_invalid') ||
        errorString.contains('invalid email')) {
      return 'Adresse email invalide';
    }

    // Erreurs de connexion
    if (errorString.contains('invalid_credentials') ||
        errorString.contains('invalid credentials') ||
        errorString.contains('email not confirmed') ||
        errorString.contains('invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    }

    // Erreurs de confirmation d'email
    if (errorString.contains('email_not_confirmed') ||
        errorString.contains('email not confirmed')) {
      return 'Veuillez confirmer votre email avant de vous connecter';
    }

    // Erreurs de compte désactivé
    if (errorString.contains('signup_disabled') ||
        errorString.contains('signup disabled')) {
      return 'Les inscriptions sont temporairement désactivées';
    }

    // Erreurs de réseau/connexion
    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return 'Problème de connexion. Vérifiez votre internet';
    }

    // Erreurs de rate limit (trop de tentatives)
    if (errorString.contains('rate limit') ||
        errorString.contains('too many requests') ||
        errorString.contains('email rate limit exceeded')) {
      return 'Trop de tentatives. Veuillez patienter quelques minutes';
    }

    // Erreurs de session expirée
    if (errorString.contains('jwt') ||
        errorString.contains('token') ||
        errorString.contains('session')) {
      return 'Session expirée. Veuillez vous reconnecter';
    }

    // Erreurs de profil/base de données
    if (errorString.contains('duplicate key') ||
        errorString.contains('postgres')) {
      return 'Problème de création de profil. Contactez le support';
    }

    // Message d'erreur générique
    return 'Une erreur est survenue. Veuillez réessayer';
  }

  /// Messages d'erreur spécifiques pour l'inscription
  static String getSignUpErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Messages spécifiques à l'inscription
    if (errorString.contains('password') && errorString.contains('length')) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    if (errorString.contains('email') && errorString.contains('format')) {
      return 'Le format de l\'email n\'est pas valide';
    }

    // Utiliser le gestionnaire général pour les autres erreurs
    return getErrorMessage(error);
  }

  /// Messages d'erreur spécifiques pour la connexion
  static String getSignInErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Messages spécifiques à la connexion
    if (errorString.contains('user not found') ||
        errorString.contains('no user found')) {
      return 'Aucun compte trouvé avec cet email';
    }

    if (errorString.contains('wrong password') ||
        errorString.contains('incorrect password')) {
      return 'Mot de passe incorrect';
    }

    // Utiliser le gestionnaire général pour les autres erreurs
    return getErrorMessage(error);
  }

  /// Messages d'erreur pour la réinitialisation de mot de passe
  static String getPasswordResetErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('user not found')) {
      return 'Aucun compte trouvé avec cet email';
    }

    if (errorString.contains('rate limit')) {
      return 'Email de réinitialisation déjà envoyé. Vérifiez votre boîte mail';
    }

    return getErrorMessage(error);
  }

  /// Messages de succès standardisés
  static const String signUpSuccess = 'Compte créé avec succès';
  static const String signInSuccess = 'Connexion réussie';
  static const String signOutSuccess = 'Déconnexion réussie';
  static const String passwordResetSuccess = 'Email de réinitialisation envoyé';
  static const String profileUpdateSuccess = 'Profil mis à jour avec succès';
  static const String emailVerificationSuccess = 'Email vérifié avec succès';
}
