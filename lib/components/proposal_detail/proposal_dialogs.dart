import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service pour les dialogs de confirmation dans les actions de proposition
class ProposalDialogs {
  /// Affiche un dialog de confirmation pour annuler une proposition
  static void showCancelConfirmationDialog({
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Annuler la proposition',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler cette proposition ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Non',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Fermer le dialog
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  /// Affiche un dialog de confirmation pour accepter une proposition
  static void showAcceptConfirmationDialog({
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Accepter la proposition',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green.shade700,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir accepter cette proposition ? Les autres propositions seront automatiquement rejetées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Non',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Fermer le dialog
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, accepter'),
          ),
        ],
      ),
    );
  }

  /// Affiche un dialog de confirmation pour rejeter une proposition
  static void showRejectConfirmationDialog({
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Rejeter la proposition',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir rejeter cette proposition ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Non',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Fermer le dialog
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, rejeter'),
          ),
        ],
      ),
    );
  }
}
