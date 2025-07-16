-- Script SQL complet pour créer toutes les tables Kipost dans Supabase
-- Basé sur SUPABASE_BACKEND.md
-- À exécuter dans l'éditeur SQL de votre dashboard Supabase

-- ================================================================
-- 1. EXTENSIONS NÉCESSAIRES
-- ================================================================

-- Activer l'extension UUID pour générer des IDs automatiquement
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================================
-- 2. TABLE PROFILES (mise à jour de l'existante)
-- ================================================================

-- Modifier la table profiles existante pour correspondre au schéma
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS average_rating NUMERIC(2,1) DEFAULT 0.0;

-- Mettre à jour le type de la colonne rating existante
ALTER TABLE profiles 
ALTER COLUMN rating TYPE NUMERIC(2,1);

-- ================================================================
-- 3. TABLE ANNOUNCEMENTS (Annonces)
-- ================================================================

CREATE TABLE IF NOT EXISTS announcements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    location JSONB DEFAULT '{}',
    budget NUMERIC,
    urgency TEXT DEFAULT 'Modéré',
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'in_progress', 'completed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS announcements_client_id_idx ON announcements(client_id);
CREATE INDEX IF NOT EXISTS announcements_status_idx ON announcements(status);
CREATE INDEX IF NOT EXISTS announcements_category_idx ON announcements(category);
CREATE INDEX IF NOT EXISTS announcements_created_at_idx ON announcements(created_at DESC);
CREATE INDEX IF NOT EXISTS announcements_location_idx ON announcements USING GIN(location);

-- ================================================================
-- 4. TABLE PROPOSALS (Propositions)
-- ================================================================

CREATE TABLE IF NOT EXISTS proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    amount NUMERIC,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Un prestataire ne peut faire qu'une seule proposition par annonce
    UNIQUE(announcement_id, provider_id)
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS proposals_announcement_id_idx ON proposals(announcement_id);
CREATE INDEX IF NOT EXISTS proposals_provider_id_idx ON proposals(provider_id);
CREATE INDEX IF NOT EXISTS proposals_status_idx ON proposals(status);
CREATE INDEX IF NOT EXISTS proposals_created_at_idx ON proposals(created_at DESC);

-- ================================================================
-- 5. TABLE CONTRACTS (Contrats)
-- ================================================================

CREATE TABLE IF NOT EXISTS contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    announcement_id UUID NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    final_price NUMERIC NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE,
    estimated_duration TEXT,
    final_location JSONB DEFAULT '{}',
    notes TEXT,
    status TEXT DEFAULT 'pending_approval' CHECK (status IN ('pending_approval', 'in_progress', 'completed', 'cancelled', 'disputed')),
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'funded', 'released', 'refunded')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS contracts_announcement_id_idx ON contracts(announcement_id);
CREATE INDEX IF NOT EXISTS contracts_proposal_id_idx ON contracts(proposal_id);
CREATE INDEX IF NOT EXISTS contracts_client_id_idx ON contracts(client_id);
CREATE INDEX IF NOT EXISTS contracts_provider_id_idx ON contracts(provider_id);
CREATE INDEX IF NOT EXISTS contracts_status_idx ON contracts(status);
CREATE INDEX IF NOT EXISTS contracts_payment_status_idx ON contracts(payment_status);
CREATE INDEX IF NOT EXISTS contracts_created_at_idx ON contracts(created_at DESC);

-- ================================================================
-- 6. TABLE REVIEWS (Évaluations)
-- ================================================================

CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    reviewee_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Un utilisateur ne peut évaluer qu'une seule fois par contrat
    UNIQUE(contract_id, reviewer_id)
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS reviews_contract_id_idx ON reviews(contract_id);
CREATE INDEX IF NOT EXISTS reviews_reviewer_id_idx ON reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS reviews_reviewee_id_idx ON reviews(reviewee_id);
CREATE INDEX IF NOT EXISTS reviews_rating_idx ON reviews(rating);
CREATE INDEX IF NOT EXISTS reviews_created_at_idx ON reviews(created_at DESC);

-- ================================================================
-- 7. ROW LEVEL SECURITY (RLS) - POLITIQUES DE SÉCURITÉ
-- ================================================================

-- Activer RLS sur toutes les nouvelles tables
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE proposals ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- POLITIQUES POUR ANNOUNCEMENTS
-- Tout le monde peut voir les annonces actives
CREATE POLICY "Anyone can view active announcements" ON announcements
    FOR SELECT USING (status = 'active');

-- Les utilisateurs peuvent voir leurs propres annonces (tous statuts)
CREATE POLICY "Users can view own announcements" ON announcements
    FOR SELECT USING (auth.uid() = client_id);

-- Les utilisateurs peuvent créer des annonces
CREATE POLICY "Authenticated users can create announcements" ON announcements
    FOR INSERT WITH CHECK (auth.uid() = client_id);

-- Les utilisateurs peuvent modifier leurs propres annonces
CREATE POLICY "Users can update own announcements" ON announcements
    FOR UPDATE USING (auth.uid() = client_id);

-- Les utilisateurs peuvent supprimer leurs propres annonces
CREATE POLICY "Users can delete own announcements" ON announcements
    FOR DELETE USING (auth.uid() = client_id);

-- POLITIQUES POUR PROPOSALS
-- Les utilisateurs peuvent voir les propositions pour leurs annonces
CREATE POLICY "Users can view proposals for their announcements" ON proposals
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM announcements 
            WHERE announcements.id = proposals.announcement_id 
            AND announcements.client_id = auth.uid()
        )
    );

-- Les utilisateurs peuvent voir leurs propres propositions
CREATE POLICY "Users can view own proposals" ON proposals
    FOR SELECT USING (auth.uid() = provider_id);

-- Les utilisateurs peuvent créer des propositions
CREATE POLICY "Authenticated users can create proposals" ON proposals
    FOR INSERT WITH CHECK (auth.uid() = provider_id);

-- Les utilisateurs peuvent modifier leurs propres propositions
CREATE POLICY "Users can update own proposals" ON proposals
    FOR UPDATE USING (auth.uid() = provider_id);

-- POLITIQUES POUR CONTRACTS
-- Seuls le client et le prestataire peuvent voir le contrat
CREATE POLICY "Contract parties can view contracts" ON contracts
    FOR SELECT USING (auth.uid() = client_id OR auth.uid() = provider_id);

-- Seuls le client et le prestataire peuvent créer des contrats
CREATE POLICY "Contract parties can create contracts" ON contracts
    FOR INSERT WITH CHECK (auth.uid() = client_id OR auth.uid() = provider_id);

-- Seuls le client et le prestataire peuvent modifier le contrat
CREATE POLICY "Contract parties can update contracts" ON contracts
    FOR UPDATE USING (auth.uid() = client_id OR auth.uid() = provider_id);

-- POLITIQUES POUR REVIEWS
-- Tout le monde peut voir les évaluations
CREATE POLICY "Anyone can view reviews" ON reviews
    FOR SELECT USING (true);

-- Seules les parties du contrat peuvent créer des évaluations
CREATE POLICY "Contract parties can create reviews" ON reviews
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM contracts 
            WHERE contracts.id = reviews.contract_id 
            AND (contracts.client_id = auth.uid() OR contracts.provider_id = auth.uid())
            AND contracts.status = 'completed'
        )
    );

-- ================================================================
-- 8. FONCTIONS ET TRIGGERS
-- ================================================================

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour mettre à jour automatiquement updated_at
CREATE TRIGGER update_announcements_updated_at
    BEFORE UPDATE ON announcements
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_proposals_updated_at
    BEFORE UPDATE ON proposals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contracts_updated_at
    BEFORE UPDATE ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour calculer la note moyenne d'un utilisateur
CREATE OR REPLACE FUNCTION calculate_user_average_rating(user_id UUID)
RETURNS NUMERIC AS $$
DECLARE
    avg_rating NUMERIC(2,1);
BEGIN
    SELECT ROUND(AVG(rating), 1) INTO avg_rating
    FROM reviews
    WHERE reviewee_id = user_id;
    
    RETURN COALESCE(avg_rating, 0.0);
END;
$$ LANGUAGE plpgsql;

-- Fonction trigger pour mettre à jour la note moyenne après une nouvelle évaluation
CREATE OR REPLACE FUNCTION update_average_rating_on_review()
RETURNS TRIGGER AS $$
BEGIN
    -- Mettre à jour la note moyenne du reviewee
    UPDATE profiles 
    SET average_rating = calculate_user_average_rating(NEW.reviewee_id)
    WHERE id = NEW.reviewee_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour la note moyenne
CREATE TRIGGER update_average_rating_after_review
    AFTER INSERT ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_average_rating_on_review();

-- Fonction pour mettre à jour le compteur de contrats terminés
CREATE OR REPLACE FUNCTION update_completed_contracts_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Si le contrat passe à "completed"
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        -- Incrémenter pour le prestataire
        UPDATE profiles 
        SET completed_contracts = completed_contracts + 1
        WHERE id = NEW.provider_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour mettre à jour le compteur de contrats
CREATE TRIGGER update_completed_contracts_after_completion
    AFTER UPDATE ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION update_completed_contracts_count();

-- ================================================================
-- 9. FONCTIONS UTILITAIRES
-- ================================================================

-- Fonction pour rechercher des annonces par proximité (si PostGIS n'est pas disponible)
CREATE OR REPLACE FUNCTION search_announcements_near_location(
    search_lat FLOAT,
    search_lng FLOAT,
    radius_km FLOAT DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    category TEXT,
    budget NUMERIC,
    urgency TEXT,
    distance_km FLOAT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.title,
        a.description,
        a.category,
        a.budget,
        a.urgency,
        -- Calcul approximatif de la distance (formule haversine simplifiée)
        (
            6371 * acos(
                cos(radians(search_lat)) * 
                cos(radians((a.location->>'latitude')::float)) * 
                cos(radians((a.location->>'longitude')::float) - radians(search_lng)) + 
                sin(radians(search_lat)) * 
                sin(radians((a.location->>'latitude')::float))
            )
        ) as distance_km,
        a.created_at
    FROM announcements a
    WHERE a.status = 'active'
    AND a.location ? 'latitude' 
    AND a.location ? 'longitude'
    HAVING (
        6371 * acos(
            cos(radians(search_lat)) * 
            cos(radians((a.location->>'latitude')::float)) * 
            cos(radians((a.location->>'longitude')::float) - radians(search_lng)) + 
            sin(radians(search_lat)) * 
            sin(radians((a.location->>'latitude')::float))
        )
    ) <= radius_km
    ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 10. DONNÉES DE TEST (OPTIONNEL)
-- ================================================================

-- Insertion de quelques catégories de test
-- INSERT INTO announcements (client_id, title, description, category, urgency) VALUES
-- ('user-id-here', 'Test Annonce', 'Description test', 'Ménage', 'Modéré');

-- ================================================================
-- FIN DU SCRIPT
-- ================================================================

-- Afficher un message de succès
DO $$
BEGIN
    RAISE NOTICE 'Toutes les tables Kipost ont été créées avec succès !';
    RAISE NOTICE 'Tables créées: profiles (modifiée), announcements, proposals, contracts, reviews';
    RAISE NOTICE 'RLS activé sur toutes les tables avec les politiques de sécurité appropriées';
    RAISE NOTICE 'Fonctions et triggers créés pour la gestion automatique des données';
END $$;
