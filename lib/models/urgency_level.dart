class UrgencyLevel {
  final String id;
  final String name;
  final String description;
  final int priority; // 1 = le plus urgent, 3 = le moins urgent
  final String timeFrame;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  UrgencyLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.timeFrame,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Factory constructor pour créer un niveau d'urgence depuis un Map (pour Firestore)
  factory UrgencyLevel.fromMap(Map<String, dynamic> map) {
    return UrgencyLevel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      priority: map['priority'] ?? 1,
      timeFrame: map['timeFrame'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isActive: map['isActive'] ?? true,
    );
  }

  // Méthode pour convertir le niveau d'urgence en Map (pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priority': priority,
      'timeFrame': timeFrame,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  // Niveaux d'urgence par défaut de l'application
  static List<UrgencyLevel> getDefaultUrgencyLevels() {
    final now = DateTime.now();
    return [
      UrgencyLevel(
        id: 'pas_urgent',
        name: 'Pas urgent',
        description: 'Travail qui peut être planifié sur 1-2 semaines',
        priority: 3,
        timeFrame: '1-2 semaines',
        createdAt: now,
        updatedAt: now,
      ),
      UrgencyLevel(
        id: 'modere',
        name: 'Modéré',
        description: 'Travail nécessitant une intervention dans les 3-7 jours',
        priority: 2,
        timeFrame: '3-7 jours',
        createdAt: now,
        updatedAt: now,
      ),
      UrgencyLevel(
        id: 'urgent',
        name: 'Urgent',
        description: 'Travail nécessitant une intervention rapide sous 24-48h',
        priority: 1,
        timeFrame: '24-48h',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Méthode pour obtenir un niveau d'urgence par son nom
  static UrgencyLevel? getUrgencyByName(String name) {
    try {
      return getDefaultUrgencyLevels().firstWhere(
        (urgency) => urgency.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Méthode pour obtenir un niveau d'urgence par son ID
  static UrgencyLevel? getUrgencyById(String id) {
    try {
      return getDefaultUrgencyLevels().firstWhere(
        (urgency) => urgency.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Méthode pour obtenir un niveau d'urgence par sa priorité
  static UrgencyLevel? getUrgencyByPriority(int priority) {
    try {
      return getDefaultUrgencyLevels().firstWhere(
        (urgency) => urgency.priority == priority,
      );
    } catch (e) {
      return null;
    }
  }

  // Méthode pour trier les niveaux d'urgence par priorité (du plus urgent au moins urgent)
  static List<UrgencyLevel> getSortedByPriority() {
    final urgencies = getDefaultUrgencyLevels();
    urgencies.sort((a, b) => a.priority.compareTo(b.priority));
    return urgencies;
  }

  @override
  String toString() {
    return 'UrgencyLevel(id: $id, name: $name, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UrgencyLevel &&
        other.id == id &&
        other.name == name &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ priority.hashCode;
  }

  // Méthode pour obtenir le label d'urgence avec le délai
  String get fullLabel => '$name ($timeFrame)';

  // Méthode pour vérifier si c'est urgent (priorité 1)
  bool get isUrgent => priority == 1;

  // Méthode pour vérifier si c'est modéré (priorité 2)
  bool get isModerate => priority == 2;

  // Méthode pour vérifier si ce n'est pas urgent (priorité 3)
  bool get isNotUrgent => priority == 3;
}
