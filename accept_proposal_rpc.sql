-- Fonction RPC pour accepter une proposition de façon sécurisée
-- Cette fonction contourne les problèmes de RLS en exécutant l'opération côté serveur

CREATE OR REPLACE FUNCTION accept_proposal(
  proposal_id uuid,
  client_id uuid
)
RETURNS json AS $$
DECLARE
  proposal_record RECORD;
  announcement_record RECORD;
  result json;
BEGIN
  -- Vérifier que la proposition existe et récupérer ses données
  SELECT * INTO proposal_record
  FROM proposals 
  WHERE id = proposal_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Proposition non trouvée: %', proposal_id;
  END IF;
  
  -- Vérifier que l'annonce appartient bien au client
  -- Utiliser le nom qualifié pour éviter l'ambiguïté
  SELECT * INTO announcement_record
  FROM announcements 
  WHERE id = proposal_record.announcement_id 
    AND announcements.client_id = accept_proposal.client_id;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Vous n''êtes pas autorisé à accepter cette proposition';
  END IF;
  
  -- Accepter la proposition
  UPDATE proposals 
  SET status = 'accepted', updated_at = now()
  WHERE id = proposal_id;
  
  -- Mettre à jour l'annonce
  UPDATE announcements 
  SET status = 'assigned', 
      selected_provider_id = proposal_record.provider_id,
      updated_at = now()
  WHERE id = proposal_record.announcement_id;
  
  -- Rejeter toutes les autres propositions
  UPDATE proposals 
  SET status = 'rejected', updated_at = now()
  WHERE announcement_id = proposal_record.announcement_id 
    AND id != proposal_id 
    AND status = 'pending';
  
  -- Retourner le résultat
  SELECT json_build_object(
    'success', true,
    'proposal_id', proposal_id,
    'announcement_id', proposal_record.announcement_id,
    'selected_provider_id', proposal_record.provider_id
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Accorder les permissions nécessaires
GRANT EXECUTE ON FUNCTION accept_proposal(uuid, uuid) TO authenticated;
