/// Configuration Supabase pour Kipost
class SupabaseConfig {
  // Ces valeurs doivent être remplacées par vos vraies clés Supabase
  static const String supabaseUrl = 'https://caokmawzazbbbojmibun.supabase.co';
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNhb2ttYXd6YXpiYmJvam1pYnVuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2OTMwMTQsImV4cCI6MjA2ODI2OTAxNH0.S9LDa71M-4VKK9LGnwgnKSPPjnfmh37hCEwQdhDSMG0";
  
  // Buckets de stockage
  static const String avatarsBucket = 'avatars';
  static const String portfolioBucket = 'portfolio-images';
  static const String contractDocumentsBucket = 'contract-documents';
  static const String chatImagesBucket = 'chat-images';
  static const String chatFilesBucket = 'chat-files';
  static const String verificationDocumentsBucket = 'verification-documents';
  
  // Tables de la base de données
  static const String profilesTable = 'profiles';
  static const String announcementsTable = 'announcements';
  static const String proposalsTable = 'proposals';
  static const String contractsTable = 'contracts';
  static const String reviewsTable = 'reviews';
  
  // Statuts des annonces
  static const String announcementStatusActive = 'active';
  static const String announcementStatusInProgress = 'in_progress';
  static const String announcementStatusCompleted = 'completed';
  static const String announcementStatusCancelled = 'cancelled';
  
  // Statuts des propositions
  static const String proposalStatusPending = 'pending';
  static const String proposalStatusAccepted = 'accepted';
  static const String proposalStatusRejected = 'rejected';
  
  // Statuts des contrats
  static const String contractStatusPendingApproval = 'pending_approval';
  static const String contractStatusInProgress = 'in_progress';
  static const String contractStatusCompleted = 'completed';
  static const String contractStatusCancelled = 'cancelled';
  static const String contractStatusDisputed = 'disputed';
  
  // Statuts de paiement
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusFunded = 'funded';
  static const String paymentStatusReleased = 'released';
  static const String paymentStatusRefunded = 'refunded';
  
  // Niveaux d'urgence
  static const String urgencyLow = 'Faible';
  static const String urgencyModerate = 'Modéré';
  static const String urgencyHigh = 'Urgent';
  
  // Catégories de services (selon le document USER_FLOW.md)
  static const List<String> serviceCategories = [
    'Ménage',
    'Bricolage',
    'Jardinage',
    'Livraison',
    'Déménagement',
    'Cours particuliers',
    'Informatique',
    'Cuisine',
    'Garde d\'enfants',
    'Soins aux animaux',
    'Beauté/Bien-être',
    'Réparations',
    'Autre',
  ];
}
