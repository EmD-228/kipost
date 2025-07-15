import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  /// Ouvre Google Maps avec les coordonnées spécifiées
  static Future<void> openGoogleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    
    if (label != null && label.isNotEmpty) {
      googleUrl += '&query_place_id=$label';
    }

    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossible d\'ouvrir Google Maps';
    }
  }

  /// Ouvre Google Maps avec une adresse textuelle
  static Future<void> openGoogleMapsWithAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossible d\'ouvrir Google Maps';
    }
  }

  /// Ouvre l'application Maps native avec les coordonnées
  static Future<void> openNativeMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    String url = 'geo:$latitude,$longitude';
    
    if (label != null && label.isNotEmpty) {
      url += '?q=$latitude,$longitude($label)';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback vers Google Maps web
      await openGoogleMaps(latitude: latitude, longitude: longitude, label: label);
    }
  }
}
