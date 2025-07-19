-- Script SQL pour ajouter les colonnes manquantes dans la base de données

-- 1. Ajouter la colonne selected_provider_id dans la table announcements
ALTER TABLE announcements 
ADD COLUMN selected_provider_id UUID REFERENCES profiles(id);

-- 2. Ajouter les colonnes pour le profil utilisateur dans la table profiles
ALTER TABLE profiles 
ADD COLUMN skills TEXT[],
ADD COLUMN portfolio_images TEXT[],
ADD COLUMN completed_contracts INTEGER DEFAULT 0;

-- 3. Ajouter des commentaires pour documenter les colonnes
COMMENT ON COLUMN announcements.selected_provider_id IS 'ID du prestataire sélectionné pour cette annonce';
COMMENT ON COLUMN profiles.skills IS 'Liste des compétences du prestataire';
COMMENT ON COLUMN profiles.portfolio_images IS 'URLs des images du portfolio';
COMMENT ON COLUMN profiles.completed_contracts IS 'Nombre de contrats terminés par le prestataire';

-- 4. Créer des index pour optimiser les requêtes
CREATE INDEX idx_announcements_selected_provider_id ON announcements(selected_provider_id);
CREATE INDEX idx_profiles_skills ON profiles USING GIN(skills);
CREATE INDEX idx_profiles_completed_contracts ON profiles(completed_contracts);
