# Guide de Migration Firebase vers Supabase pour Kipost

Ce document explique comment migrer l'application Kipost de Firebase vers Supabase en utilisant l'architecture définie dans `SUPABASE_BACKEND.md` et `FRONTEND_BACKEND_INTERACTION.md`.

## 1. Préparation de la Migration

### 1.1. Installation des Dépendances Supabase

```yaml
dependencies:
  # Remplacer Firebase par Supabase
  supabase_flutter: ^2.3.4
  
  # Supprimer ces dépendances Firebase
  # firebase_core: ^2.30.0
  # firebase_auth: ^4.19.0
  # cloud_firestore: ^4.17.0
```

### 1.2. Configuration Supabase

1. **Créer un projet Supabase** sur https://supabase.com
2. **Configurer les variables** dans `lib/config/supabase_config.dart`
3. **Remplacer** `main.dart` par `main_supabase.dart`

## 2. Migration des Modèles de Données

### 2.1. Anciens Modèles Firebase → Nouveaux Modèles Supabase

| Firebase | Supabase | Changements |
|----------|----------|-------------|
| `UserModel` | `ProfileModel` | Structure selon schéma `profiles` |
| `Announcement` | `AnnouncementModel` | Champs `urgency`, `budget` vs `price` |
| Pas de modèle | `ProposalModel` | Nouveau modèle pour les propositions |
| Pas de modèle | `ContractModel` | Nouveau modèle pour les contrats |
| Pas de modèle | `ReviewModel` | Nouveau modèle pour les évaluations |

### 2.2. Nouveaux Modèles Créés

Les modèles Supabase sont disponibles dans `lib/models/supabase/` :
- ✅ `ProfileModel` - Profils utilisateur
- ✅ `AnnouncementModel` - Annonces de services
- ✅ `ProposalModel` - Propositions des prestataires
- ✅ `ContractModel` - Contrats entre client/prestataire
- ✅ `ReviewModel` - Évaluations et avis

## 3. Migration des Services

### 3.1. Services Créés pour Supabase

| Service | Fonctionnalités | Status |
|---------|----------------|--------|
| `SupabaseService` | Client singleton, initialisation | ✅ Créé |
| `AuthService` | Authentification utilisateur | ✅ Créé |
| `ProfileService` | Gestion des profils | ✅ Créé |
| `AnnouncementService` | Gestion des annonces | ✅ Créé |
| `ProposalService` | Gestion des propositions | ✅ Créé |
| `ContractService` | Gestion des contrats | ✅ Créé |
| `ReviewService` | Gestion des évaluations | ✅ Créé |
| `StorageService` | Gestion des fichiers | ✅ Créé |

### 3.2. Correspondance Firebase → Supabase

```dart
// AVANT (Firebase)
FirebaseFirestore.instance.collection('annonces').add(data);

// APRÈS (Supabase)
supabase.from('announcements').insert(data);
```

## 4. Migration des Contrôleurs

### 4.1. AnnouncementController

Le contrôleur existant utilise Firebase. Il faudra :

1. **Remplacer les imports** :
```dart
// Supprimer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ajouter
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/announcement_service.dart';
```

2. **Utiliser les services Supabase** :
```dart
// AVANT
FirebaseFirestore.instance.collection('annonces').add(data);

// APRÈS
final announcementService = AnnouncementService();
await announcementService.createAnnouncement(...);
```

### 4.2. Nouveaux Contrôleurs à Créer

- `ProposalController` - Gestion des propositions
- `ContractController` - Gestion des contrats
- `ReviewController` - Gestion des évaluations

## 5. Migration de la Base de Données

### 5.1. Schéma Supabase à Créer

Exécuter les scripts SQL suivants dans Supabase :

```sql
-- Table profiles (étend auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  avatar_url TEXT,
  location JSONB,
  average_rating NUMERIC(2,1) DEFAULT 0,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table announcements
CREATE TABLE announcements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  client_id UUID REFERENCES profiles(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  location JSONB NOT NULL,
  budget NUMERIC,
  urgency TEXT DEFAULT 'Modéré',
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table proposals
CREATE TABLE proposals (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  announcement_id UUID REFERENCES announcements(id) NOT NULL,
  provider_id UUID REFERENCES profiles(id) NOT NULL,
  message TEXT NOT NULL,
  amount NUMERIC,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table contracts
CREATE TABLE contracts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  announcement_id UUID REFERENCES announcements(id) NOT NULL,
  proposal_id UUID REFERENCES proposals(id) NOT NULL,
  client_id UUID REFERENCES profiles(id) NOT NULL,
  provider_id UUID REFERENCES profiles(id) NOT NULL,
  final_price NUMERIC NOT NULL,
  start_time TIMESTAMPTZ,
  estimated_duration TEXT,
  final_location JSONB,
  notes TEXT,
  status TEXT DEFAULT 'pending_approval',
  payment_status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table reviews
CREATE TABLE reviews (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  contract_id UUID REFERENCES contracts(id) NOT NULL,
  reviewer_id UUID REFERENCES profiles(id) NOT NULL,
  reviewee_id UUID REFERENCES profiles(id) NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 5.2. Politiques de Sécurité (RLS)

Activer Row Level Security selon `SUPABASE_BACKEND.md`.

### 5.3. Migration des Données

Créer des scripts pour migrer les données existantes de Firebase vers Supabase.

## 6. Migration de l'Interface Utilisateur

### 6.1. Écrans à Adapter

Les écrans existants devront être adaptés pour :
- Utiliser les nouveaux modèles Supabase
- Afficher les nouvelles fonctionnalités (propositions, contrats, évaluations)
- Gérer les nouveaux flux utilisateur

### 6.2. Nouveaux Écrans à Créer

Selon `USER_FLOW.md` :
- Écrans de gestion des propositions
- Écrans de négociation de contrats
- Écrans d'évaluation mutuelle
- Écrans de chat intégré
- Écrans de calendrier

## 7. Tests et Validation

### 7.1. Tests de Migration

1. **Tester l'authentification** Supabase
2. **Vérifier les CRUD** pour chaque entité
3. **Tester les permissions** RLS
4. **Valider les nouveaux flux** utilisateur

### 7.2. Déploiement Progressif

1. **Phase 1** : Déployer en parallèle (Firebase + Supabase)
2. **Phase 2** : Migrer les utilisateurs par étapes
3. **Phase 3** : Désactiver Firebase définitivement

## 8. Avantages de la Migration

### 8.1. Fonctionnalités Nouvelles

- ✅ **Système de propositions** complet
- ✅ **Gestion de contrats** avec négociation
- ✅ **Évaluations mutuelles** client/prestataire
- ✅ **Géolocalisation** avancée avec PostGIS
- ✅ **Temps réel** natif avec Supabase

### 8.2. Architecture Améliorée

- ✅ **Base de données relationnelle** PostgreSQL
- ✅ **Sécurité** renforcée avec RLS
- ✅ **Scalabilité** meilleure
- ✅ **Coûts** optimisés

## 9. Prochaines Étapes

1. **Configurer** le projet Supabase
2. **Créer** le schéma de base de données
3. **Tester** les services créés
4. **Adapter** les contrôleurs existants
5. **Créer** les nouveaux contrôleurs
6. **Migrer** les écrans UI
7. **Tester** l'application complète
8. **Déployer** progressivement

---

*Cette migration permettra à Kipost d'avoir une architecture plus robuste et des fonctionnalités avancées selon les spécifications définies dans les documents d'architecture.*
