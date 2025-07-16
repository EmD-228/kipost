# User Flow de l'Application Kipost

Ce document décrit le parcours utilisateur complet au sein de l'application Kipost, en séparant les flux pour les deux principaux acteurs : le **Client** (personne qui poste une annonce) et le **Prestataire** (personne qui propose un service).

---

## 1. Flux Commun

### 1.1. Premier Lancement et Authentification
1.  **Écran de Bienvenue / Onboarding**
    *   L'utilisateur ouvre l'application pour la première fois.
    *   Présentation rapide des concepts clés de Kipost.
    *   Boutons : `Se connecter` et `S'inscrire`.

2.  **Inscription (Sign Up)**
    *   L'utilisateur clique sur `S'inscrire`.
    *   **Écran d'inscription** :
        *   Champs : Nom, Prénom, Adresse e-mail, Mot de passe, Confirmation du mot de passe.
        *   Bouton `Créer un compte`.
    *   -> Redirection vers l'écran principal (Dashboard) après une inscription réussie.

3.  **Connexion (Sign In)**
    *   L'utilisateur clique sur `Se connecter`.
    *   **Écran de connexion** :
        *   Champs : Adresse e-mail, Mot de passe.
        *   Lien : "Mot de passe oublié ?".
        *   Bouton `Se connecter`.
    *   -> Redirection vers l'écran principal (Dashboard) après une connexion réussie.

---

## 2. Flux du Client

Le Client est un utilisateur qui a un besoin et souhaite trouver un prestataire.

### 2.1. Création d'une Annonce
1.  **Dashboard (Écran d'accueil)**
    *   L'utilisateur voit un résumé de son activité (ses annonces en cours).
    *   Un bouton flottant (Floating Action Button) `+` est visible pour `Créer une annonce`.

2.  **Processus de Création (assistant en plusieurs étapes)**
    *   L'utilisateur clique sur `+`.
    *   **Étape 1 : Sélection de la Catégorie**
        *   Affiche une liste de catégories de services (ex: Ménage, Bricolage, Informatique).
        *   L'utilisateur sélectionne une catégorie. -> `Suivant`.
    *   **Étape 2 : Détails de l'Annonce**
        *   Champs : Titre, Description, Localisation, Budget/Prix (optionnel).
        *   -> `Suivant`.
    *   **Étape 3 : Niveau d'Urgence**
        *   Options : Faible, Modéré, Urgent.
        *   -> `Suivant`.
    *   **Étape 4 : Aperçu et Publication**
        *   Récapitulatif de toutes les informations saisies.
        *   Bouton `Publier l'annonce`.

3.  **Confirmation**
    *   Un message de succès s'affiche ("Votre annonce a été publiée !").
    *   L'utilisateur est redirigé vers la liste de ses annonces.

### 2.2. Gestion des Annonces et Sélection du Prestataire
1.  **Mes Annonces**
    *   Accessible depuis le menu ou le tableau de bord.
    *   Liste de toutes les annonces créées par le Client, avec leur statut (Active, En cours, Terminée).

2.  **Voir les Propositions**
    *   Le Client clique sur une de ses annonces `Active`.
    *   -> **Écran de Détail de l'Annonce** : Affiche les informations de l'annonce et un bouton `Voir les propositions (X)`.
    *   Le Client clique sur `Voir les propositions`.
    *   -> **Écran des Propositions (`proposals_screen.dart`)** :
        *   Liste de toutes les propositions reçues pour cette annonce.
        *   Chaque proposition affiche le profil du prestataire, son message et son prix.

3.  **Proposer un Contrat**
    *   Le Client clique sur une proposition qui l'intéresse.
    *   Un dialogue de confirmation apparaît : "Voulez-vous proposer un contrat à [Nom du Prestataire] ?".
    *   Le Client confirme.
    *   -> **Écran de Création de Contrat** :
        *   Les informations du prestataire et de l'annonce sont pré-remplies.
        *   Champs à remplir par le client :
            *   `Prix final` (peut être basé sur la proposition).
            *   `Date et heure de début`.
            *   `Durée estimée` (ex: 2 heures, 3 jours).
            *   `Lieu précis du travail`.
            *   `Notes additionnelles` pour le contrat.
        *   Bouton `Envoyer la proposition de contrat`.
    *   **Action système** :
        *   Un "Contrat" est créé avec le statut `En attente de validation`.
        *   Une notification est envoyée au prestataire pour l'informer de la proposition de contrat.

### 2.3. Négociation et Suivi du Contrat
1.  **Suivi du Contrat**
    *   Le Client peut voir le statut de ses contrats envoyés (En attente, Accepté, Refusé).
    *   Si le prestataire accepte le contrat :
        *   Le statut de l'annonce passe à `En cours`.
        *   Le statut de la proposition sélectionnée passe à `Acceptée`.
        *   Les autres propositions pour cette annonce sont automatiquement `Refusées`.
        *   Le contrat est finalisé et le travail est officiellement planifié.
        *   Le Client est invité à provisionner le paiement (voir Flux de Paiement).
    *   Le Client peut communiquer avec le prestataire via la messagerie intégrée.
    *   Une fois le travail terminé, le Client peut marquer le travail comme `Terminé`, ce qui déclenche la libération du paiement et le flux d'évaluation.
    *   Le Client peut initier une procédure d'annulation (voir Flux d'Annulation).

---

## 3. Flux du Prestataire

Le Prestataire est un utilisateur qui cherche à offrir ses services.

### 3.1. Recherche d'Annonces et Envoi de Propositions
1.  **Dashboard (Écran d'accueil)**
    *   Affiche une liste de toutes les annonces `Actives` publiées par les clients.
    *   Possibilité de filtrer par catégorie ou de rechercher par mots-clés.

2.  **Consulter une Annonce**
    *   Le Prestataire clique sur une annonce qui l'intéresse.
    *   -> **Écran de Détail de l'Annonce** :
        *   Affiche tous les détails (description, localisation, urgence, budget).
        *   Affiche le profil du Client.
        *   Un bouton `Faire une proposition` est visible.

3.  **Faire une Proposition**
    *   Le Prestataire clique sur `Faire une proposition`.
    *   -> **Écran de Création de Proposition** :
        *   Champ `Message` : Pour se présenter et décrire son offre.
        *   Champ `Montant proposé` (si applicable).
        *   Bouton `Envoyer ma proposition`.

4.  **Confirmation**
    *   Un message de succès s'affiche ("Votre proposition a été envoyée !").
    *   Le Prestataire est redirigé vers la liste de ses propositions envoyées.

### 3.2. Gestion des Propositions et des Travaux
1.  **Mes Propositions**
    *   Accessible depuis le menu.
    *   Liste de toutes les propositions envoyées par le Prestataire, avec leur statut (En attente, Acceptée, Refusée).

2.  **Réception et Gestion du Contrat**
    *   Le Prestataire reçoit une notification : "Vous avez reçu une proposition de contrat pour [Titre de l'annonce]".
    *   -> **Écran de Détail du Contrat** :
        *   Affiche tous les termes proposés par le client (prix, date, durée, lieu, etc.).
        *   Boutons : `Accepter le contrat`, `Refuser`, et `Faire une contre-proposition`.
    *   Si le prestataire accepte :
        *   Le contrat est finalisé.
        *   Le travail est ajouté à son calendrier et à sa liste de travaux.
        *   Une notification de confirmation est envoyée au client.
    *   Si le prestataire refuse, il peut indiquer une raison (optionnel). Le contrat est annulé.
    *   S'il fait une contre-proposition, un nouveau cycle de validation commence côté client.

3.  **Gestion du Travail**
    *   Le Prestataire accède à l'écran "Mes Travaux".
    *   Il voit les détails du travail à effectuer (basés sur le contrat accepté).
    *   Il peut communiquer avec le client via la messagerie intégrée (voir Flux de Messagerie).
    *   Il peut mettre à jour le statut du travail (ex: `En cours`).
    *   Il peut initier une procédure d'annulation (voir Flux d'Annulation).

---

## 4. Flux Commun (Profil)

1.  **Mon Profil**
    *   Accessible depuis le menu principal pour les deux types d'utilisateurs.
    *   Permet de voir et de modifier ses informations personnelles (nom, photo de profil).
    *   Affiche un historique des travaux réalisés, la note moyenne et les évaluations reçues.
    *   Pour les prestataires, affiche un badge "Profil Vérifié" et permet de gérer son portfolio.
    *   Bouton `Se déconnecter`.

---

## 5. Fonctionnalités Transversales

### 5.1. Flux de Messagerie (Chat)
Cette fonctionnalité permet une communication directe et contextuelle entre un Client et un Prestataire après la sélection pour un travail.

1.  **Accès au Chat**
    *   Depuis l'écran de détail d'un "Contrat" accepté, un bouton `Contacter` ou une icône de message est disponible.
    *   L'accès n'est possible que pour les travaux ayant le statut `En cours`.

2.  **Interface de Chat**
    *   L'utilisateur clique sur le bouton de contact.
    *   -> **Écran de Chat** :
        *   Le nom du destinataire et le titre de l'annonce concernée sont affichés en en-tête.
        *   L'historique des messages entre les deux utilisateurs pour ce travail spécifique est affiché.
        *   Un champ de saisie permet de taper un nouveau message.
        *   Un bouton `Envoyer`.

3.  **Réception de Messages**
    *   Lorsqu'un utilisateur reçoit un nouveau message, il reçoit une notification push/in-app.
    *   Un indicateur de message non lu apparaît sur l'icône de messagerie ou sur l'onglet correspondant.
    *   Toutes les notifications sont également visibles dans le Centre de Notifications.

### 5.2. Flux du Calendrier
Le calendrier offre une vue d'ensemble des travaux planifiés.

1.  **Accès au Calendrier**
    *   Un onglet ou une icône `Calendrier` est accessible depuis la barre de navigation principale.

2.  **Vue Calendrier**
    *   Affiche une vue mensuelle par défaut, avec possibilité de basculer en vue hebdomadaire ou journalière.
    *   Les jours où un ou plusieurs travaux sont planifiés sont marqués visuellement (ex: un point de couleur).

3.  **Interaction avec le Calendrier**
    *   L'utilisateur clique sur une date marquée.
    *   Une liste des travaux prévus pour ce jour s'affiche sous le calendrier.
    *   Chaque élément de la liste est un résumé du travail (ex: "Ménage pour Annonce X", "Développement - Projet Y").
    *   L'utilisateur clique sur un résumé de travail.
    *   -> Redirection vers l'écran de détail du Contrat correspondant.

4.  **Planification d'un Travail**
    *   La planification ne se fait pas directement dans le calendrier.
    *   C'est l'acceptation du contrat par le prestataire qui finalise la date et l'heure.
    *   Une fois le contrat accepté, l'événement est automatiquement ajouté au calendrier des deux utilisateurs.

---

## 6. Flux Avancés : Cycle de Vie et Confiance

### 6.1. Flux de Paiement (Sécurisé via Escrow)
1.  **Provision par le Client** : Après l'acceptation du contrat par le prestataire, le Client est invité à payer le montant convenu. L'argent est conservé par Kipost (escrow) et n'est pas encore versé au prestataire.
2.  **Confirmation de Fin de Travail** : Une fois le travail effectué, le Client marque le contrat comme `Terminé`.
3.  **Libération du Paiement** : Le Client est invité à `Valider et libérer le paiement`. Après confirmation, les fonds sont transférés au prestataire (moins la commission de Kipost).
4.  **Gestion des Litiges** : Si le Client n'est pas satisfait, il peut ouvrir un litige au lieu de libérer le paiement. Un processus de médiation est alors enclenché.

### 6.2. Flux d'Évaluation et Notation (Post-Travail)
1.  **Invitation à Évaluer** : Une fois le paiement libéré, le Client et le Prestataire reçoivent une notification les invitant à s'évaluer mutuellement.
2.  **Écran d'Évaluation** :
    *   Notation de 1 à 5 étoiles.
    *   Champ de commentaire public.
    *   Champ de feedback privé (optionnel, pour l'amélioration de Kipost).
3.  **Publication** : Les évaluations sont publiées sur le profil de chaque utilisateur uniquement lorsque les deux parties ont soumis leur évaluation, ou après une période de 14 jours, pour garantir l'objectivité.

### 6.3. Flux de Négociation et d'Annulation
1.  **Contre-proposition** : Si le prestataire n'est pas d'accord avec les termes du contrat initial, il peut faire une contre-proposition en modifiant les champs (prix, date...). Le contrat retourne au Client avec un statut `En négociation` pour validation.
2.  **Annulation de Contrat** :
    *   Avant le début du travail, l'une ou l'autre des parties peut demander l'annulation.
    *   Des conditions s'appliquent (ex: annulation gratuite jusqu'à 24h avant).
    *   L'autre partie doit confirmer l'annulation. En cas de désaccord, un litige peut être ouvert.

### 6.4. Flux de Confiance et Profils Avancés
1.  **Vérification de Profil** : Un prestataire peut soumettre des documents (ex: pièce d'identité) via un formulaire sécurisé pour obtenir un badge "Profil Vérifié", augmentant la confiance des clients.
2.  **Gestion du Portfolio** : Un prestataire peut, depuis son profil, ajouter des photos de ses réalisations passées, avec des descriptions, pour mettre en valeur ses compétences.

### 6.5. Centre de Notifications
1.  **Accès** : Une icône "cloche" dans l'AppBar donne accès au Centre de Notifications.
2.  **Contenu** : Il liste de manière chronologique tous les événements importants :
    *   Nouveaux messages de chat.
    *   Propositions de contrat reçues.
    *   Contrats acceptés/refusés.
    *   Rappels de travaux à venir.
    *   Invitations à évaluer un utilisateur.
    *   Notifications système de Kipost.
3.  **Gestion** : L'utilisateur peut marquer les notifications comme lues.
