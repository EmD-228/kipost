-- Script pour modifier la contrainte de statut des annonces

-- 1. Supprimer l'ancienne contrainte (remplacez 'announcements_status_check' par le nom réel si différent)
ALTER TABLE announcements DROP CONSTRAINT IF EXISTS announcements_status_check;

-- 2. Ajouter une nouvelle contrainte qui inclut 'assigned'
ALTER TABLE announcements 
ADD CONSTRAINT announcements_status_check 
CHECK (status IN ('active', 'inactive', 'completed', 'cancelled', 'assigned', 'draft', 'pending', 'published'));

-- 3. Vérifier que la contrainte a été ajoutée
SELECT 
    con.conname AS constraint_name,
    pg_get_constraintdef(con.oid) AS constraint_definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'public' 
AND rel.relname = 'announcements'
AND con.contype = 'c'
AND con.conname = 'announcements_status_check';

-- 4. Optionnel : Mettre à jour les annonces qui ont une proposition acceptée
-- (Décommentez si vous voulez mettre à jour les données existantes)
-- UPDATE announcements 
-- SET status = 'assigned' 
-- WHERE id IN (
--     SELECT DISTINCT announcement_id 
--     FROM proposals 
--     WHERE status = 'accepted'
-- );

-- 5. Créer un commentaire pour documenter les statuts possibles
COMMENT ON COLUMN announcements.status IS 'Statut de l''annonce: active, inactive, completed, cancelled, assigned, draft, pending, published';
