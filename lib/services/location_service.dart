import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Vérifie les permissions de localisation
  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Obtient la position actuelle de l'utilisateur
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        throw Exception('Permission de localisation refusée');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'obtention de la position: ${e.toString()}');
    }
  }

  /// Convertit les coordonnées en adresse lisible
  static Future<Map<String, dynamic>> getAddressFromCoordinates(
    double latitude, 
    double longitude
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        
        return {
          'city': placemark.locality ?? placemark.subAdministrativeArea ?? 'Ville inconnue',
          'country': placemark.country ?? 'Côte d\'Ivoire',
          'latitude': latitude,
          'longitude': longitude,
          'address': '${placemark.street ?? ''} ${placemark.subLocality ?? ''}'.trim(),
          'postalCode': placemark.postalCode ?? '',
          'administrativeArea': placemark.administrativeArea ?? '',
        };
      } else {
        return {
          'city': 'Ville inconnue',
          'country': 'Côte d\'Ivoire',
          'latitude': latitude,
          'longitude': longitude,
          'address': '',
          'postalCode': '',
          'administrativeArea': '',
        };
      }
    } catch (e) {
      // En cas d'erreur, retourner des données par défaut
      return {
        'city': 'Ville inconnue',
        'country': 'Côte d\'Ivoire',
        'latitude': latitude,
        'longitude': longitude,
        'address': '',
        'postalCode': '',
        'administrativeArea': '',
      };
    }
  }

  /// Obtient la position actuelle avec l'adresse
  static Future<Map<String, dynamic>> getCurrentLocationWithAddress() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) {
        throw Exception('Impossible d\'obtenir la position');
      }

      final locationData = await getAddressFromCoordinates(
        position.latitude, 
        position.longitude
      );

      return locationData;
    } catch (e) {
      throw Exception('Erreur lors de l\'obtention de la localisation: ${e.toString()}');
    }
  }

  /// Vérifie si les coordonnées sont valides
  static bool isValidCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }

  /// Formate l'adresse pour l'affichage
  static String formatAddressForDisplay(Map<String, dynamic> location) {
    final city = location['city'] ?? '';
    final country = location['country'] ?? '';
    
    if (city.isNotEmpty && country.isNotEmpty) {
      return '$city, $country';
    } else if (city.isNotEmpty) {
      return city;
    } else if (country.isNotEmpty) {
      return country;
    }
    
    return 'Localisation inconnue';
  }
}
