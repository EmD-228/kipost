// Code à utiliser après avoir modifié la contrainte de base de données

// Remplacer 'status': 'inactive' par 'status': 'assigned'
await _client
    .from('announcements')
    .update({
      'status': 'assigned', // Statut approprié pour une annonce assignée
      'selected_provider_id': proposal.providerId,
    })
    .eq('id', proposal.announcementId);
