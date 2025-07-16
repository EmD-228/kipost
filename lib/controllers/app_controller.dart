import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AppController extends GetxController {
  // Observables pour l'état de la localisation
  final RxBool isLocationServiceEnabled = false.obs;
  final RxBool hasLocationPermission = false.obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxString currentAddress = ''.obs;
  final RxBool isLoadingLocation = false.obs;

  // Vérifier et initialiser la localisation
  Future<void> checkLocationAndInitialize() async {
    try {
      isLoadingLocation.value = true;
      
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      isLocationServiceEnabled.value = serviceEnabled;
      
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      await _handleLocationPermission(permission);
      
    } catch (e) {
      printError(info: 'Erreur lors de l\'initialisation de la localisation: $e');
      Get.snackbar(
        'Erreur',
        'Impossible d\'accéder à la localisation',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // Afficher une dialogue pour activer les services de localisation
  void _showLocationServiceDialog() {
    // Vérifier si un dialogue est déjà ouvert
    if (Get.isDialogOpen ?? false) return;
    
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Empêcher la fermeture avec le bouton retour
        child: AlertDialog(
          title: const Text('Services de localisation désactivés'),
          content: const Text(
            'Les services de localisation sont désactivés sur votre appareil. '
            'Veuillez les activer dans les paramètres pour utiliser cette fonctionnalité.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }
              },
              child: const Text('Ignorer'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }
                await Geolocator.openLocationSettings();
                // Revérifier après avoir ouvert les paramètres
                Future.delayed(const Duration(seconds: 2), () {
                  checkLocationAndInitialize();
                });
              },
              child: const Text('Ouvrir les paramètres'),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Empêcher la fermeture en cliquant à l'extérieur
      navigatorKey: Get.key, // Utiliser la clé du navigateur GetX
    );
  }

  // Gérer les permissions de localisation
  Future<void> _handleLocationPermission(LocationPermission permission) async {
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      hasLocationPermission.value = false;
      Get.snackbar(
        'Permission refusée',
        'L\'accès à la localisation a été refusé',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      hasLocationPermission.value = false;
      _showPermissionDeniedDialog();
      return;
    }

    // Permission accordée
    hasLocationPermission.value = true;
    await getCurrentLocation();
  }

  // Afficher une dialogue pour les permissions refusées définitivement
  void _showPermissionDeniedDialog() {
    // Vérifier si un dialogue est déjà ouvert
    if (Get.isDialogOpen ?? false) return;
    
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Empêcher la fermeture avec le bouton retour
        child: AlertDialog(
          title: const Text('Permission de localisation refusée'),
          content: const Text(
            'L\'accès à la localisation a été refusé définitivement. '
            'Veuillez l\'autoriser manuellement dans les paramètres de l\'application.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }
              },
              child: const Text('Ignorer'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }
                await Geolocator.openAppSettings();
                // Revérifier après avoir ouvert les paramètres
                Future.delayed(const Duration(seconds: 2), () {
                  checkLocationAndInitialize();
                });
              },
              child: const Text('Ouvrir les paramètres'),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Empêcher la fermeture en cliquant à l'extérieur
      navigatorKey: Get.key, // Utiliser la clé du navigateur GetX
    );
  }

  // Obtenir la position actuelle
  Future<void> getCurrentLocation() async {
    try {
      isLoadingLocation.value = true;
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      currentPosition.value = position;
      printInfo(info: 'Position actuelle: $position');

      // Obtenir l\'adresse
      await getAddressFromPosition(position);
      
    } catch (e) {
      printError(info: 'Erreur lors de l\'obtention de la position: $e');
      Get.snackbar(
        'Erreur',
        'Impossible d\'obtenir votre position actuelle',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // Obtenir l'adresse à partir des coordonnées
  Future<void> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        currentAddress.value = 
          '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        printInfo(info: 'Adresse actuelle: ${currentAddress.value}');
      }
    } catch (e) {
      printError(info: 'Erreur lors de l\'obtention de l\'adresse: $e');
    }
  }

  // Rafraîchir la localisation
  Future<void> refreshLocation() async {
    await checkLocationAndInitialize();
  }

  // Méthode héritée pour la compatibilité (deprecated)
  @deprecated
  Future<Position> determinePosition() async {
    if (!isLocationServiceEnabled.value) {
      return Future.error('Location services are disabled.');
    }
    
    if (!hasLocationPermission.value) {
      return Future.error('Location permissions are denied');
    }
    
    return await Geolocator.getCurrentPosition();
  }

  // Méthode pour vérifier périodiquement l'état et réafficher les dialogues si nécessaire
  void checkAndShowDialogsIfNeeded() {
    // Si aucun dialogue n'est ouvert et que les services sont désactivés
    if (!(Get.isDialogOpen ?? false) && !isLocationServiceEnabled.value) {
      _showLocationServiceDialog();
      return;
    }
    
    // Si aucun dialogue n'est ouvert et que les permissions sont refusées définitivement
    if (!(Get.isDialogOpen ?? false) && 
        isLocationServiceEnabled.value && 
        !hasLocationPermission.value) {
      // Vérifier à nouveau les permissions pour s'assurer qu'elles sont bien refusées définitivement
      Geolocator.checkPermission().then((permission) {
        if (permission == LocationPermission.deniedForever) {
          _showPermissionDeniedDialog();
        }
      });
    }
  }
}
