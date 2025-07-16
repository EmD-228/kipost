import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Service de gestion du stockage de fichiers
class StorageService {
  final SupabaseService _supabaseService = SupabaseService();
  
  SupabaseClient get _client => _supabaseService.client;

  /// Upload un avatar utilisateur
  Future<String> uploadAvatar(File file) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final fileName = 'avatar_${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '${currentUser.id}/$fileName';

      await _client.storage.from('avatars').upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      return _client.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'avatar: $e');
    }
  }

  /// Upload une image de portfolio
  Future<String> uploadPortfolioImage(File file, String fileName) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final path = '${currentUser.id}/$fileName';

      await _client.storage.from('portfolio-images').upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      return _client.storage.from('portfolio-images').getPublicUrl(path);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image portfolio: $e');
    }
  }

  /// Upload multiple images de portfolio
  Future<List<String>> uploadMultiplePortfolioImages(List<File> files) async {
    final urls = <String>[];
    
    for (int i = 0; i < files.length; i++) {
      final fileName = 'portfolio_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final url = await uploadPortfolioImage(files[i], fileName);
      urls.add(url);
    }
    
    return urls;
  }

  /// Upload un document de contrat
  Future<String> uploadContractDocument(File file, String contractId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final fileName = 'contract_${contractId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final path = '$contractId/$fileName';

      await _client.storage.from('contract-documents').upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      return _client.storage.from('contract-documents').getPublicUrl(path);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload du document: $e');
    }
  }

  /// Upload une image de conversation (chat)
  Future<String> uploadChatImage(File file, String conversationId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final fileName = 'chat_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$conversationId/$fileName';

      await _client.storage.from('chat-images').upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      return _client.storage.from('chat-images').getPublicUrl(path);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image chat: $e');
    }
  }

  /// Upload un fichier de conversation (chat)
  Future<String> uploadChatFile(File file, String conversationId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final extension = file.path.split('.').last;
      final fileName = 'file_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final path = '$conversationId/$fileName';

      await _client.storage.from('chat-files').upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      return _client.storage.from('chat-files').getPublicUrl(path);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload du fichier chat: $e');
    }
  }

  /// Supprime un fichier du stockage
  Future<void> deleteFile(String bucketName, String path) async {
    try {
      await _client.storage.from(bucketName).remove([path]);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du fichier: $e');
    }
  }

  /// Supprime un avatar utilisateur
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      final uri = Uri.parse(avatarUrl);
      final pathSegments = uri.pathSegments;
      
      // Récupérer le chemin du fichier à partir de l'URL
      if (pathSegments.length >= 3) {
        final userId = pathSegments[pathSegments.length - 2];
        final fileName = pathSegments[pathSegments.length - 1];
        final path = '$userId/$fileName';
        
        await _client.storage.from('avatars').remove([path]);
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'avatar: $e');
    }
  }

  /// Supprime toutes les images de portfolio d'un utilisateur
  Future<void> deleteAllPortfolioImages() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final fileList = await _client.storage
          .from('portfolio-images')
          .list(path: currentUser.id);

      final filePaths = fileList.map((file) => '${currentUser.id}/${file.name}').toList();
      
      if (filePaths.isNotEmpty) {
        await _client.storage.from('portfolio-images').remove(filePaths);
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression des images portfolio: $e');
    }
  }

  /// Récupère la liste des fichiers d'un bucket
  Future<List<FileObject>> getFilesList(String bucketName, {String? path}) async {
    try {
      return await _client.storage.from(bucketName).list(path: path);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des fichiers: $e');
    }
  }

  /// Récupère les informations d'un fichier
  Future<Map<String, dynamic>?> getFileInfo(String bucketName, String filePath) async {
    try {
      final response = await _client.storage.from(bucketName).info(filePath);
      return {
        'name': response.name,
        'id': response.id,
        'updated_at': response.updatedAt,
        'created_at': response.createdAt,
        'last_accessed_at': response.lastAccessedAt,
        'metadata': response.metadata,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des informations du fichier: $e');
    }
  }

  /// Génère une URL signée pour un accès temporaire
  Future<String> createSignedUrl(String bucketName, String filePath, {int expiresIn = 3600}) async {
    try {
      return await _client.storage
          .from(bucketName)
          .createSignedUrl(filePath, expiresIn);
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'URL signée: $e');
    }
  }

  /// Télécharge un fichier
  Future<List<int>> downloadFile(String bucketName, String filePath) async {
    try {
      return await _client.storage.from(bucketName).download(filePath);
    } catch (e) {
      throw Exception('Erreur lors du téléchargement du fichier: $e');
    }
  }

  /// Vérifie si un fichier existe
  Future<bool> fileExists(String bucketName, String filePath) async {
    try {
      await _client.storage.from(bucketName).info(filePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Copie un fichier
  Future<void> copyFile(String bucketName, String fromPath, String toPath) async {
    try {
      await _client.storage.from(bucketName).copy(fromPath, toPath);
    } catch (e) {
      throw Exception('Erreur lors de la copie du fichier: $e');
    }
  }

  /// Déplace un fichier
  Future<void> moveFile(String bucketName, String fromPath, String toPath) async {
    try {
      await _client.storage.from(bucketName).move(fromPath, toPath);
    } catch (e) {
      throw Exception('Erreur lors du déplacement du fichier: $e');
    }
  }

  /// Obtient l'URL publique d'un fichier
  String getPublicUrl(String bucketName, String filePath) {
    return _client.storage.from(bucketName).getPublicUrl(filePath);
  }

  /// Valide le type de fichier
  bool isValidImageType(String fileName) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = fileName.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }

  /// Valide le type de document
  bool isValidDocumentType(String fileName) {
    final validExtensions = ['pdf', 'doc', 'docx', 'txt'];
    final extension = fileName.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }

  /// Valide la taille du fichier (en bytes)
  bool isValidFileSize(File file, int maxSizeInBytes) {
    return file.lengthSync() <= maxSizeInBytes;
  }
}
