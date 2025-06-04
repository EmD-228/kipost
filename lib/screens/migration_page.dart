import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../utils/migrate_proposals.dart';

/// Page de migration pour mettre à jour la base de données
/// À utiliser une seule fois pour migrer les données existantes
class MigrationPage extends StatefulWidget {
  const MigrationPage({super.key});

  @override
  State<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  bool _isMigrating = false;
  String _migrationLog = '';

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _log('✅ Firebase initialisé');
    } catch (e) {
      _log('❌ Erreur Firebase: $e');
    }
  }

  void _log(String message) {
    setState(() {
      _migrationLog += '$message\n';
    });
    print(message);
  }

  Future<void> _runMigration() async {
    if (_isMigrating) return;
    
    setState(() {
      _isMigrating = true;
      _migrationLog = '';
    });

    try {
      _log('🔄 Début de la migration...');
      
      // 1. Vérifier l'état actuel
      await _checkStatus();
      
      // 2. Exécuter la migration
      await ProposalMigration.migrateExistingProposals();
      
      // 3. Vérifier le résultat
      await _checkStatus();
      
      _log('✅ Migration terminée avec succès !');
      
    } catch (e) {
      _log('❌ Erreur de migration: $e');
    } finally {
      setState(() {
        _isMigrating = false;
      });
    }
  }

  Future<void> _checkStatus() async {
    try {
      await ProposalMigration.checkMigrationStatus();
    } catch (e) {
      _log('❌ Erreur de vérification: $e');
    }
  }

  Future<void> _cleanup() async {
    if (_isMigrating) return;
    
    setState(() {
      _isMigrating = true;
    });

    try {
      _log('🧹 Début du nettoyage...');
      await ProposalMigration.cleanupOrphanedProposalIds();
      _log('✅ Nettoyage terminé !');
    } catch (e) {
      _log('❌ Erreur de nettoyage: $e');
    } finally {
      setState(() {
        _isMigrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migration Base de Données'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Migration des Propositions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cette migration ajoute les IDs des propositions aux annonces existantes '
                      'pour améliorer les performances du système de propositions.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isMigrating ? null : _checkStatus,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Vérifier État'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isMigrating ? null : _runMigration,
                    icon: _isMigrating 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(_isMigrating ? 'Migration...' : 'Démarrer Migration'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isMigrating ? null : _cleanup,
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Nettoyer les Orphelins'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journal de Migration',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _migrationLog.isEmpty ? 'Aucun log pour le moment...' : _migrationLog,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
