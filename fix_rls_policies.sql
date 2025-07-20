-- Script pour diagnostiquer et corriger les politiques RLS
-- Exécutez ce script dans Supabase SQL Editor

-- 1. Vérifier les politiques existantes sur la table proposals
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'proposals';

-- 2. Créer une politique pour permettre aux clients de modifier les propositions sur leurs annonces
DROP POLICY IF EXISTS "Clients can update proposals on their announcements" ON proposals;

CREATE POLICY "Clients can update proposals on their announcements" 
ON proposals 
FOR UPDATE 
TO authenticated 
USING (
    EXISTS (
        SELECT 1 
        FROM announcements 
        WHERE announcements.id = proposals.announcement_id 
        AND announcements.client_id = auth.uid()
    )
);

-- 3. Politique pour permettre aux prestataires de modifier leurs propres propositions
DROP POLICY IF EXISTS "Providers can update their own proposals" ON proposals;

CREATE POLICY "Providers can update their own proposals" 
ON proposals 
FOR UPDATE 
TO authenticated 
USING (provider_id = auth.uid());

-- 4. Politique pour permettre la lecture des propositions
DROP POLICY IF EXISTS "Users can read relevant proposals" ON proposals;

CREATE POLICY "Users can read relevant proposals" 
ON proposals 
FOR SELECT 
TO authenticated 
USING (
    provider_id = auth.uid() 
    OR 
    EXISTS (
        SELECT 1 
        FROM announcements 
        WHERE announcements.id = proposals.announcement_id 
        AND announcements.client_id = auth.uid()
    )
);

-- 5. Vérifier que RLS est activé
ALTER TABLE proposals ENABLE ROW LEVEL SECURITY;

-- 6. Afficher les nouvelles politiques
SELECT 
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'proposals';
