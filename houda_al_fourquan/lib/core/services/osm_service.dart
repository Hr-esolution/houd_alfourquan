import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class OSMService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Get city name from latitude and longitude using OSM Nominatim API
  Future<String> getCity(double lat, double lon) async {
    try {
      debugPrint('=== Recherche de ville par coordonnées: $lat, $lon ===');

      final uri = Uri.parse('$_baseUrl/reverse').replace(
        queryParameters: {
          'format': 'json',
          'lat': lat.toString(),
          'lon': lon.toString(),
          'zoom': '12', // Plus précis pour les villes
          'addressdetails': '1',
          'accept-language': 'fr', // Préférer les noms en français
        },
      );

      debugPrint('URL: $uri');

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'HoudaAlFourquan/1.0 (mindcom2018@gmail.com)'},
      );

      debugPrint('Statut HTTP: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('Réponse OSM: $data');

        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          // Priorité aux villes marocaines
          final city = address['city'] as String?;
          final municipality = address['municipality'] as String?;
          final town = address['town'] as String?;
          final village = address['village'] as String?;
          final suburb = address['suburb'] as String?;
          final county = address['county'] as String?;
          final state = address['state'] as String?;
          final country = address['country'] as String?;

          debugPrint(
            'City: $city, Municipality: $municipality, Town: $town, Village: $village, Suburb: $suburb, County: $county, State: $state, Country: $country',
          );

          // Construire le nom de la ville
          String cityName;
          
          // Pour le Maroc, prioriser city/town/village
          if (country == 'Maroc' || country == 'Morocco') {
            cityName = city ?? municipality ?? town ?? village ?? suburb ?? county ?? 'Maroc';
          } else {
            cityName = city ?? municipality ?? town ?? village ?? county ?? 'Unknown';
          }

          // Si on obtient "Casablanca" mais que les coordonnées sont différentes,
          // c'est probablement un fallback de l'API
          if (cityName == 'Casablanca' && lat > 30.0 && lat < 40.0 && lon > -10.0 && lon < 10.0) {
            // Vérifier si c'est vraiment Casablanca (33.5731, -7.5898)
            final distanceFromCasablanca = _calculateDistance(
              lat, lon, 33.5731, -7.5898
            );
            if (distanceFromCasablanca > 50) {
              // Plus de 50km de Casablanca, utiliser une autre référence
              cityName = suburb ?? town ?? village ?? county ?? state ?? 'Maroc';
            }
          }

          debugPrint('Ville trouvée: $cityName');
          return cityName;
        }
      }

      return 'Unknown';
    } catch (e) {
      debugPrint('Erreur getCity: $e');
      return 'Unknown';
    }
  }

  /// Calculer la distance entre deux points en km (formule de Haversine)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = 
      math.sin(dLat) * math.sin(dLat) +
      (_toRadians(lat1) * _toRadians(lat2)) * 
      math.sin(dLon) * math.sin(dLon);
    
    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (math.pi / 180.0);

  /// Search for cities by name - worldwide search
  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    try {
      debugPrint('=== Recherche de villes: $query ===');

      // Search worldwide with country filter option
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'format': 'json',
          'q': query,
          'limit': '20',
          'addressdetails': '1',
          'countrycodes': 'ma,dz,tn,ly,mr', // Prioriser Maroc + pays arabes
        },
      );

      debugPrint('URL: $uri');

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'HoudaAlFourquan/1.0 (mindcom2018@gmail.com)'},
      );

      debugPrint('Statut HTTP: ${response.statusCode}');
      debugPrint(
        'Réponse: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        debugPrint('Nombre de résultats bruts: ${data.length}');

        final results = data
            .where((item) {
              final type = item['type'] as String?;
              final address = item['address'] as Map<String, dynamic>?;
              final country = address?['country'] as String?;
              final city =
                  address?['city'] ?? address?['town'] ?? address?['village'];

              // Filter for city types only
              final isCityType =
                  type == 'city' ||
                  type == 'town' ||
                  type == 'village' ||
                  type == 'state' ||
                  type == 'administrative';

              debugPrint('Ville: $city, Pays: $country, Type: $type');

              return isCityType && city != null;
            })
            .take(20)
            .map((item) => item as Map<String, dynamic>)
            .toList();

        debugPrint('Résultats filtrés: ${results.length}');
        return results;
      }

      return [];
    } catch (e) {
      debugPrint('Erreur recherche villes: $e');
      return [];
    }
  }

  /// Get coordinates from city name
  Future<Map<String, dynamic>?> getCityCoordinates(String cityName) async {
    try {
      final results = await searchCities(cityName);
      if (results.isNotEmpty) {
        final first = results.first;
        return {
          'lat': double.parse(first['lat']),
          'lon': double.parse(first['lon']),
          'name': first['display_name'] as String,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
