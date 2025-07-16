# Guide d'Interaction Frontend-Backend pour Kipost

Ce document est un guide technique pour les développeurs de l'application Kipost. Il détaille comment le frontend (Flutter) doit interagir avec le backend (Supabase) pour chaque fonctionnalité définie dans le `USER_FLOW.md`.

---

## 0. Setup Initial et Modèles de Données

### Setup (dans `main.dart`)
Initialisez le client Supabase au démarrage de l'application.

```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'VOTRE_URL_SUPABASE',
    anonKey: 'VOTRE_CLE_ANON_SUPABASE',maintenant tu vas 
  );
  
  runApp(MyApp());
}

// Helper pour un accès facile dans toute l'application
final supabase = Supabase.instance.client;
```

### Modèles de Données Côté Flutter
Créez des classes Dart correspondant aux tables Supabase pour faciliter la manipulation des données (ex: `UserModel`, `AnnouncementModel`, `ContractModel`).

---

## 1. Flux d'Authentification

### 1.1. Inscription (Sign Up)
- **Action Utilisateur :** Remplit le formulaire d'inscription et clique sur "Créer un compte".
- **Méthode Supabase :**
  ```dart
  final AuthResponse res = await supabase.auth.signUp(
    email: email,
    password: password,
    data: {'first_name': firstName, 'last_name': lastName}, // Données pour le profil
  );
  ```
- **Logique Backend :**
  1. `auth.signUp()` crée un nouvel utilisateur dans `auth.users`.
  2. Un **trigger** SQL sur la table `auth.users` copie l'`id`, `first_name` et `last_name` dans la table `profiles` pour créer le profil public de l'utilisateur.

### 1.2. Connexion (Sign In)
- **Action Utilisateur :** Remplit le formulaire de connexion et clique sur "Se connecter".
- **Méthode Supabase :**
  ```dart
  final AuthResponse res = await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
  ```

### 1.3. Déconnexion (Sign Out)
- **Action Utilisateur :** Clique sur le bouton "Se déconnecter".
- **Méthode Supabase :**
  ```dart
  await supabase.auth.signOut();
  ```

---

## 2. Flux du Client

### 2.1. Créer une Annonce
- **Action Utilisateur :** Valide le formulaire de création d'annonce.
- **Méthode Supabase :**
  ```dart
  await supabase.from('announcements').insert({
    'client_id': supabase.auth.currentUser!.id,
    'title': title,
    'description': description,
    'category': category,
    'location': {'country': '...', 'city': '...', 'latitude': ..., 'longitude': ...}, // Objet JSON
    'budget': budget,
    'urgency': urgency,
  });
  ```

### 2.2. Voir ses Annonces
- **Action Utilisateur :** Accède à l'écran "Mes Annonces".
- **Méthode Supabase :**
  ```dart
  final myAnnouncements = await supabase
      .from('announcements')
      .select()
      .eq('client_id', supabase.auth.currentUser!.id);
  ```

### 2.3. Voir les Propositions pour une Annonce
- **Action Utilisateur :** Ouvre l'écran de détail d'une de ses annonces.
- **Méthode Supabase :**
  ```dart
  // On récupère les propositions ET le profil du prestataire en une seule requête
  final proposals = await supabase
      .from('proposals')
      .select('*, profiles(*)') // Jointure avec la table profiles
      .eq('announcement_id', announcementId);
  ```

### 2.4. Proposer un Contrat
- **Action Utilisateur :** Valide le formulaire de création de contrat.
- **Méthode Supabase :**
  ```dart
  await supabase.from('contracts').insert({
    'announcement_id': announcementId,
    'proposal_id': proposalId,
    'client_id': supabase.auth.currentUser!.id,
    'provider_id': providerId,
    'final_price': finalPrice,
    'start_time': startTime.toIso8601String(),
    // ... autres champs du contrat
  });
  ```
- **Logique Backend :** L'insertion déclenche l'Edge Function `on-contract-proposed` qui envoie une notification au prestataire.

---

## 3. Flux du Prestataire

### 3.1. Consulter les Annonces Actives
- **Action Utilisateur :** Ouvre le tableau de bord principal.
- **Méthode Supabase :**
  ```dart
  final activeAnnouncements = await supabase
      .from('announcements')
      .select('*, profiles(*)') // Jointure pour afficher les infos du client
      .eq('status', 'active');
  ```

### 3.2. Faire une Proposition
- **Action Utilisateur :** Soumet le formulaire de proposition.
- **Méthode Supabase :**
  ```dart
  await supabase.from('proposals').insert({
    'announcement_id': announcementId,
    'provider_id': supabase.auth.currentUser!.id,
    'message': message,
    'amount': amount,
  });
  ```

### 3.3. Gérer une Proposition de Contrat
- **Action Utilisateur :** Accepte ou refuse un contrat proposé par un client.
- **Méthode Supabase :**
  ```dart
  // Pour accepter
  await supabase
      .from('contracts')
      .update({'status': 'in_progress'})
      .eq('id', contractId);

  // Pour refuser
  await supabase
      .from('contracts')
      .update({'status': 'cancelled'})
      .eq('id', contractId);
  ```
- **Logique Backend :** La mise à jour du statut à `in_progress` déclenche l'Edge Function `on-contract-accepted`.

---

## 4. Profil et Fonctionnalités Communes

### 4.1. Gestion du Profil
- **Action Utilisateur :** Met à jour son profil (nom, avatar).
- **Méthodes Supabase :**
  ```dart
  // Mettre à jour le nom
  await supabase.from('profiles').update({
    'first_name': newFirstName,
    'last_name': newLastName,
  }).eq('id', supabase.auth.currentUser!.id);

  // Uploader un nouvel avatar
  final file = File('path/to/image.jpg');
  final path = '${supabase.auth.currentUser!.id}/avatar.jpg';
  await supabase.storage.from('avatars').upload(path, file, fileOptions: const FileOptions(upsert: true));
  final imageUrl = supabase.storage.from('avatars').getPublicUrl(path);
  
  // Mettre à jour l'URL dans le profil
  await supabase.from('profiles').update({'avatar_url': imageUrl}).eq('id', supabase.auth.currentUser!.id);
  ```

### 4.2. Soumettre une Évaluation
- **Action Utilisateur :** Remplit et envoie le formulaire d'évaluation après un travail.
- **Méthode Supabase :**
  ```dart
  await supabase.from('reviews').insert({
    'contract_id': contractId,
    'reviewer_id': supabase.auth.currentUser!.id,
    'reviewee_id': otherUserId,
    'rating': rating, // de 1 à 5
    'comment': comment,
  });
  ```
- **Logique Backend :** L'insertion déclenche l'Edge Function `calculate-average-rating`.

---

## 5. Fonctionnalités Temps Réel (Realtime)

Pour les fonctionnalités comme le chat ou les notifications en direct, on utilisera les abonnements Realtime de Supabase.

### 5.1. Chat en Direct
- **Structure :** Nécessite une table `messages` (`id`, `contract_id`, `sender_id`, `content`, `created_at`).
- **Écouter les nouveaux messages :**
  ```dart
  final messageStream = supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('contract_id', currentContractId)
      .order('created_at');

  // Utiliser ce stream dans un StreamBuilder pour afficher les messages
  ```
- **Envoyer un message :**
  ```dart
  await supabase.from('messages').insert({
    'contract_id': currentContractId,
    'sender_id': supabase.auth.currentUser!.id,
    'content': messageContent,
  });
  ```

### 5.2. Centre de Notifications
- **Structure :** Nécessite une table `notifications` (`id`, `user_id`, `title`, `body`, `is_read`).
- **Écouter les nouvelles notifications :**
  ```dart
  final notificationStream = supabase
      .from('notifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', supabase.auth.currentUser!.id)
      .order('created_at', ascending: false);
  ```
- **Marquer comme lue :**
  ```dart
  await supabase
      .from('notifications')
      .update({'is_read': true})
      .eq('id', notificationId);
  ```
