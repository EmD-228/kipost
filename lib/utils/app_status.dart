/// Statuts des propositions
class ProposalStatus {
  static const String pending = 'pending';      // En attente
  static const String accepted = 'accepted';    // Acceptée
  static const String rejected = 'rejected';    // Rejetée
  static const String cancelled = 'cancelled';  // Annulée
  
  /// Liste de tous les statuts de proposition
  static const List<String> all = [
    pending,
    accepted,
    rejected,
    cancelled,
  ];
  
  /// Obtenir le libellé français du statut
  static String getLabel(String status) {
    switch (status) {
      case pending:
        return 'En attente';
      case accepted:
        return 'Acceptée';
      case rejected:
        return 'Rejetée';
      case cancelled:
        return 'Annulée';
      default:
        return 'Inconnu';
    }
  }
  
  /// Vérifier si le statut est valide
  static bool isValid(String status) {
    return all.contains(status);
  }
}

/// Statuts des annonces
class AnnouncementStatus {
  static const String active = 'active';        // Active
  static const String paused = 'paused';        // En pause
  static const String completed = 'completed';  // Terminée
  static const String cancelled = 'cancelled';  // Annulée
  static const String expired = 'expired';      // Expirée
  
  /// Liste de tous les statuts d'annonce
  static const List<String> all = [
    active,
    paused,
    completed,
    cancelled,
    expired,
  ];
  
  /// Obtenir le libellé français du statut
  static String getLabel(String status) {
    switch (status) {
      case active:
        return 'Active';
      case paused:
        return 'En pause';
      case completed:
        return 'Terminée';
      case cancelled:
        return 'Annulée';
      case expired:
        return 'Expirée';
      default:
        return 'Inconnu';
    }
  }
  
  /// Vérifier si le statut est valide
  static bool isValid(String status) {
    return all.contains(status);
  }
}

/// Statuts des travaux (work_details)
class WorkStatus {
  static const String planned = 'planned';      // Planifié
  static const String inProgress = 'in_progress'; // En cours
  static const String completed = 'completed';  // Terminé
  static const String cancelled = 'cancelled';  // Annulé
  static const String postponed = 'postponed';  // Reporté
  
  /// Liste de tous les statuts de travail
  static const List<String> all = [
    planned,
    inProgress,
    completed,
    cancelled,
    postponed,
  ];
  
  /// Obtenir le libellé français du statut
  static String getLabel(String status) {
    switch (status) {
      case planned:
        return 'Planifié';
      case inProgress:
        return 'En cours';
      case completed:
        return 'Terminé';
      case cancelled:
        return 'Annulé';
      case postponed:
        return 'Reporté';
      default:
        return 'Inconnu';
    }
  }
  
  /// Vérifier si le statut est valide
  static bool isValid(String status) {
    return all.contains(status);
  }
}

/// Statuts de paiement
class PaymentStatus {
  static const String pending = 'pending';      // En attente
  static const String paid = 'paid';            // Payé
  static const String failed = 'failed';        // Échec
  static const String refunded = 'refunded';    // Remboursé
  static const String cancelled = 'cancelled';  // Annulé
  
  /// Liste de tous les statuts de paiement
  static const List<String> all = [
    pending,
    paid,
    failed,
    refunded,
    cancelled,
  ];
  
  /// Obtenir le libellé français du statut
  static String getLabel(String status) {
    switch (status) {
      case pending:
        return 'En attente';
      case paid:
        return 'Payé';
      case failed:
        return 'Échec';
      case refunded:
        return 'Remboursé';
      case cancelled:
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }
  
  /// Vérifier si le statut est valide
  static bool isValid(String status) {
    return all.contains(status);
  }
}

/// Statuts des utilisateurs
class UserStatus {
  static const String active = 'active';        // Actif
  static const String inactive = 'inactive';    // Inactif
  static const String suspended = 'suspended';  // Suspendu
  static const String banned = 'banned';        // Banni
  
  /// Liste de tous les statuts d'utilisateur
  static const List<String> all = [
    active,
    inactive,
    suspended,
    banned,
  ];
  
  /// Obtenir le libellé français du statut
  static String getLabel(String status) {
    switch (status) {
      case active:
        return 'Actif';
      case inactive:
        return 'Inactif';
      case suspended:
        return 'Suspendu';
      case banned:
        return 'Banni';
      default:
        return 'Inconnu';
    }
  }
  
  /// Vérifier si le statut est valide
  static bool isValid(String status) {
    return all.contains(status);
  }
}

/// Classe pour gérer tous les statuts de l'application Kipost
class AppStatus {
}
