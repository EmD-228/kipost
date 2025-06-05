import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Factory constructor pour créer une catégorie depuis un Map (pour Firestore)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: _getIconFromString(map['icon'] ?? 'more'),
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isActive: map['isActive'] ?? true,
    );
  }

  // Méthode pour convertir la catégorie en Map (pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': _getStringFromIcon(icon),
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  // Méthode pour créer une copie avec des modifications
  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Méthodes utilitaires pour la conversion des icônes
  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'bezier':
        return Iconsax.bezier;
      case 'setting_4':
        return Iconsax.setting_4;
      case 'flash_1':
        return Iconsax.flash_1;
      case 'brush_2':
        return Iconsax.brush_2;
      case 'car':
        return Iconsax.car;
      case 'tree':
        return Iconsax.tree;
      case 'monitor':
        return Iconsax.monitor;
      case 'more':
        return Iconsax.more;
      default:
        return Iconsax.more;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    if (icon == Iconsax.bezier) return 'bezier';
    if (icon == Iconsax.setting_4) return 'setting_4';
    if (icon == Iconsax.flash_1) return 'flash_1';
    if (icon == Iconsax.brush_2) return 'brush_2';
    if (icon == Iconsax.car) return 'car';
    if (icon == Iconsax.tree) return 'tree';
    if (icon == Iconsax.monitor) return 'monitor';
    return 'more';
  }

  // Catégories par défaut de l'application
  static List<Category> getDefaultCategories() {
    final now = DateTime.now();
    return [
      Category(
        id: 'menuiserie',
        name: 'Menuiserie',
        icon: Iconsax.bezier,
        description: 'Travaux de menuiserie, fabrication et réparation de meubles',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'plomberie',
        name: 'Plomberie',
        icon: Iconsax.setting_4,
        description: 'Installation et réparation de systèmes de plomberie',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'electricite',
        name: 'Électricité',
        icon: Iconsax.flash_1,
        description: 'Installation et dépannage électrique',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'aide_menagere',
        name: 'Aide ménagère',
        icon: Iconsax.brush_2,
        description: 'Services de ménage et d\'entretien domestique',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'transport',
        name: 'Transport',
        icon: Iconsax.car,
        description: 'Services de transport et livraison',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'jardinage',
        name: 'Jardinage',
        icon: Iconsax.tree,
        description: 'Entretien de jardins et espaces verts',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'informatique',
        name: 'Informatique',
        icon: Iconsax.monitor,
        description: 'Services informatiques et techniques',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'autre',
        name: 'Autre',
        icon: Iconsax.more,
        description: 'Autres services non catégorisés',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Méthode pour obtenir une catégorie par son nom
  static Category? getCategoryByName(String name) {
    try {
      return getDefaultCategories().firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Méthode pour obtenir une catégorie par son ID
  static Category? getCategoryById(String id) {
    try {
      return getDefaultCategories().firstWhere(
        (category) => category.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        icon.hashCode;
  }
}
