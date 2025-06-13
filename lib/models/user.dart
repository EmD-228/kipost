import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isClient; // Peut poster des annonces
  final bool isProvider; // Peut répondre aux annonces
  final String? avatar;
  final String? phone;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isClient = true, // Par défaut, tout le monde peut être client
    this.isProvider = false, // Le rôle prestataire doit être activé
    this.avatar,
    this.phone,
    this.location,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Factory constructor pour créer un utilisateur depuis un Map (pour Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isClient: map['isClient'] ?? true,
      isProvider: map['isProvider'] ?? false,
      avatar: map['avatar'],
      phone: map['phone'],
      location: map['location'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Méthode pour convertir l'utilisateur en Map (pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isClient': isClient,
      'isProvider': isProvider,
      'avatar': avatar,
      'phone': phone,
      'location': location,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
    };
  }

  // Méthode pour créer une copie avec des modifications
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isClient,
    bool? isProvider,
    String? avatar,
    String? phone,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isClient: isClient ?? this.isClient,
      isProvider: isProvider ?? this.isProvider,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Méthodes utilitaires pour les rôles
  bool get canCreateAnnouncements => isClient;
  bool get canSubmitProposals => isProvider;
  bool get hasBothRoles => isClient && isProvider;
  
  String get primaryRole {
    if (hasBothRoles) return 'Client & Prestataire';
    if (isProvider) return 'Prestataire';
    return 'Client';
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode;
  }
}
