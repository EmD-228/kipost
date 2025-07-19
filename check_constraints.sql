-- Script pour vérifier les contraintes existantes sur la table announcements

-- 1. Vérifier les contraintes CHECK existantes
SELECT 
    con.conname AS constraint_name,
    con.consrc AS constraint_definition,
    pg_get_constraintdef(con.oid) AS constraint_full_definition
FROM pg_constraint con
JOIN pg_class rel ON rel.oid = con.conrelid
JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
WHERE nsp.nspname = 'public' 
AND rel.relname = 'announcements'
AND con.contype = 'c';

-- 2. Vérifier la définition de la colonne status
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'announcements' 
AND column_name = 'status';

-- 3. Vérifier les valeurs actuelles dans la colonne status
SELECT status, COUNT(*) as count
FROM announcements
GROUP BY status
ORDER BY count DESC;
