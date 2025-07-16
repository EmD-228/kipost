# Architecture Backend avec Supabase pour Kipost

Ce document décrit l'architecture backend proposée pour l'application Kipost en utilisant la plateforme Supabase. Il couvre la structure de la base de données, l'authentification, le stockage et la logique métier côté serveur.

---

## 1. Schéma de la Base de Données (PostgreSQL)

La base de données sera structurée autour des tables suivantes. La sécurité sera assurée par des politiques de **Row Level Security (RLS)** pour que les utilisateurs ne puissent accéder qu'aux données qui les concernent.

### Table `profiles`
Cette table étend la table `auth.users` de Supabase pour stocker les informations publiques et privées des utilisateurs.

| Nom de la colonne | Type de données | Description                                                                 |
| ----------------- | --------------- | --------------------------------------------------------------------------- |
| `id` (PK)         | `uuid`          | Clé primaire, référence `auth.users.id`.                                     |
| `first_name`      | `text`          | Prénom de l'utilisateur.                                                    |
| `last_name`       | `text`          | Nom de l'utilisateur.                                                       |
| `avatar_url`      | `text`          | URL de l'image de profil, stockée dans Supabase Storage.                    |
| `location`        | `jsonb`         | Localisation de l'utilisateur `{"country": "...", "city": "...", "latitude": ..., "longitude": ...}`. |
| `average_rating`  | `numeric(2,1)`  | Note moyenne du prestataire (calculée).                                     |
| `is_verified`     | `boolean`       | `true` si le profil du prestataire a été vérifié. `default: false`.         |
| `created_at`      | `timestamptz`   | Date de création du profil.                                                 |

### Table `announcements` (Annonces)
| Nom de la colonne | Type de données | Description                                                                 |
| ----------------- | --------------- | --------------------------------------------------------------------------- |
| `id` (PK)         | `uuid`          | Clé primaire. `default: uuid_generate_v4()`.                                |
| `client_id` (FK)  | `uuid`          | Référence `profiles.id` du client qui a posté l'annonce.                    |
| `title`           | `text`          | Titre de l'annonce.                                                         |
| `description`     | `text`          | Description détaillée du besoin.                                            |
| `category`        | `text`          | Catégorie du service (ex: "Ménage", "Bricolage").                           |
| `location`        | `jsonb`         | Lieu du service `{"country": "...", "city": "...", "latitude": ..., "longitude": ...}`. |
| `budget`          | `numeric`       | Budget estimé par le client (optionnel).                                    |
| `urgency`         | `text`          | Niveau d'urgence (ex: "Faible", "Modéré", "Urgent").                        |
| `status`          | `text`          | Statut de l'annonce (`active`, `in_progress`, `completed`, `cancelled`). `default: 'active'`. |
| `created_at`      | `timestamptz`   | Date de création.                                                           |

### Table `proposals` (Propositions)
| Nom de la colonne    | Type de données | Description                                                                 |
| -------------------- | --------------- | --------------------------------------------------------------------------- |
| `id` (PK)            | `uuid`          | Clé primaire.                                                               |
| `announcement_id` (FK) | `uuid`          | Référence `announcements.id`.                                               |
| `provider_id` (FK)   | `uuid`          | Référence `profiles.id` du prestataire qui fait la proposition.             |
| `message`            | `text`          | Message du prestataire pour le client.                                      |
| `amount`             | `numeric`       | Montant proposé par le prestataire (optionnel).                             |
| `status`             | `text`          | Statut (`pending`, `accepted`, `rejected`). `default: 'pending'`.           |
| `created_at`         | `timestamptz`   | Date de création.                                                           |

### Table `contracts` (Contrats)
| Nom de la colonne    | Type de données | Description                                                                 |
| -------------------- | --------------- | --------------------------------------------------------------------------- |
| `id` (PK)            | `uuid`          | Clé primaire.                                                               |
| `announcement_id` (FK) | `uuid`          | Référence `announcements.id`.                                               |
| `proposal_id` (FK)   | `uuid`          | Référence `proposals.id` qui a mené au contrat.                             |
| `client_id` (FK)     | `uuid`          | Référence `profiles.id` du client.                                          |
| `provider_id` (FK)   | `uuid`          | Référence `profiles.id` du prestataire.                                     |
| `final_price`        | `numeric`       | Prix final convenu.                                                         |
| `start_time`         | `timestamptz`   | Date et heure de début du travail.                                          |
| `estimated_duration` | `text`          | Durée estimée (ex: "2 heures").                                             |
| `final_location`     | `jsonb`         | Lieu précis du travail `{"country": "...", "city": "...", "latitude": ..., "longitude": ...}`. |
| `notes`              | `text`          | Notes additionnelles du contrat.                                            |
| `status`             | `text`          | Statut (`pending_approval`, `in_progress`, `completed`, `cancelled`, `disputed`). |
| `payment_status`     | `text`          | Statut du paiement (`pending`, `funded`, `released`, `refunded`).           |
| `created_at`         | `timestamptz`   | Date de création.                                                           |

### Table `reviews` (Évaluations)
| Nom de la colonne | Type de données | Description                                                                 |
| ----------------- | --------------- | --------------------------------------------------------------------------- |
| `id` (PK)         | `uuid`          | Clé primaire.                                                               |
| `contract_id` (FK) | `uuid`          | Référence `contracts.id`.                                                   |
| `reviewer_id` (FK) | `uuid`          | Référence `profiles.id` de celui qui écrit l'évaluation.                    |
| `reviewee_id` (FK) | `uuid`          | Référence `profiles.id` de celui qui est évalué.                            |
| `rating`          | `integer`       | Note de 1 à 5.                                                              |
| `comment`         | `text`          | Commentaire public.                                                         |
| `created_at`      | `timestamptz`   | Date de création.                                                           |

> **Note sur la géolocalisation :** L'utilisation du type `jsonb` est flexible. Pour des requêtes géospatiales avancées (ex: "trouver les prestataires à moins de 5km"), il serait recommandé d'activer l'extension **PostGIS** sur Supabase et d'utiliser le type de données `geography`.

---

## 2. Authentification et Sécurité (RLS)

*   **Auth Supabase :** On utilisera le système d'authentification intégré pour la connexion par e-mail/mot de passe.
*   **RLS Policies :** Des politiques de sécurité au niveau des lignes seront créées pour chaque table. Exemples :
    *   Un utilisateur peut voir toutes les annonces `actives`, mais ne peut modifier/supprimer que les siennes.
    *   Un utilisateur ne peut voir que les propositions qu'il a faites ou reçues.
    *   Seuls le client et le prestataire concernés peuvent voir les détails d'un contrat.
    *   Un utilisateur ne peut modifier que son propre profil.

---

## 3. Stockage (Supabase Storage)

*   **Bucket `avatars` :**
    *   Public.
    *   Politique RLS : Un utilisateur authentifié ne peut `uploader` ou `modifier` que son propre avatar (`path` correspondant à son `user_id`).
*   **Bucket `portfolio-images` :**
    *   Public.
    *   Politique RLS : Un utilisateur ne peut `uploader` ou `modifier` que les images de son propre portfolio.
*   **Bucket `verification-documents` :**
    *   **Privé**.
    *   Politique RLS : Un utilisateur ne peut qu'`uploader` des documents. Seuls des administrateurs (via une clé de service) peuvent les lire.

---

## 4. Logique Métier (Edge Functions)

Les Edge Functions (serverless) seront utilisées pour exécuter de la logique sécurisée et des actions automatisées.

*   **`on-contract-proposed`**
    *   **Déclencheur :** Insertion dans la table `contracts`.
    *   **Action :** Crée une notification pour le prestataire.

*   **`on-contract-accepted`**
    *   **Déclencheur :** Mise à jour du statut d'un contrat à `in_progress`.
    *   **Actions :**
        1.  Met à jour le statut de l'`announcement` correspondante à `in_progress`.
        2.  Met à jour le statut de toutes les autres `proposals` pour cette annonce à `rejected`.
        3.  Crée une notification pour le client et pour les prestataires dont la proposition a été refusée.

*   **`on-contract-completed`**
    *   **Déclencheur :** Mise à jour du statut d'un contrat à `completed`.
    *   **Action :** Crée des notifications pour le client et le prestataire les invitant à laisser une évaluation.

*   **`calculate-average-rating`**
    *   **Déclencheur :** Insertion dans la table `reviews`.
    *   **Action :** Recalcule la note moyenne pour le `reviewee_id` et met à jour la colonne `average_rating` dans la table `profiles`.

*   **Fonctions de paiement (ex: avec Stripe)**
    *   **`create-payment-intent` :** Fonction appelée par le client pour créer une session de paiement.
    *   **`stripe-webhook` :** Endpoint pour écouter les webhooks de Stripe, par exemple pour confirmer qu'un paiement a été provisionné (`payment_status` -> `funded`).
