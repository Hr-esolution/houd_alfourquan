# 🕌 Système de Géolocalisation - Application SALAT

> **Documentation complète** pour la gestion de la position, des villes et des adresses dans l'application SALAT.

---

## 📋 Table des Matières

1. [Dépendances Requises](#-1-dépendances-requises-pubspecyaml)
2. [Architecture du Système](#-2-architecture-du-système)
3. [LocationService - Position GPS](#-3-locationservice---position-gps)
4. [OSMService - Géocodage](#-4-osmservice---géocodage)
5. [HomeController - Gestion Ville](#-5-homecontroller---gestion-ville)
6. [HiveService - Cache Local](#-6-hiveservice---cache-local)
7. [UI Widgets](#-7-ui-widgets)
8. [Configuration Plates-formes](#-8-configuration-plates-formes)
9. [Cas d'Usage SALAT](#-9-cas-dusage-salat)
10. [Dépannage](#-10-dépannage)

---

## 📦 1. Dépendances Requises (pubspec.yaml)

```yaml
dependencies:
  # Position GPS
  geolocator: ^14.0.2
  
  # Carte interactive (pour Qibla map)
  flutter_map: ^8.1.1
  latlong2: ^0.9.1
  
  # Stockage local (cache position)
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  get_storage: ^2.1.1
  
  # Gestion d'état
  get: ^4.6.6
  
  # HTTP pour API OSM
  http: ^1.1.0
```

---

## 🏗️ 2. Architecture du Système

```
┌─────────────────────────────────────────────────────────┐
│  UI (Widgets)                                           │
│  ├── CityWidget            → Affiche ville actuelle     │
│  ├── QiblaView             → Carte + boussole           │
│  └── HomeView              → Page principale            │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Controllers                                            │
│  ├── HomeController        → État ville + prières       │
│  ├── LocationController    → Position GPS (optionnel)   │
│  └── QiblaController       → Direction + carte          │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Services                                               │
│  ├── LocationService       → GPS + permissions          │
│  └── OSMService            → API Nominatim (reverse)    │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Data Layer                                             │
│  └── HiveService           → Cache local (position)     │
└─────────────────────────────────────────────────────────┘
```

---

## 📍 3. LocationService - Position GPS

**Fichier :** `lib/core/services/location_service.dart`

### Fonctionnalités

| Méthode | Description |
|---------|-------------|
| `getCurrentLocation()` | Obtient position GPS avec permissions |
| `hasPermission()` | Vérifie permission de localisation |
| `openAppSettings()` | Ouvre paramètres pour permissions |
| `openLocationSettings()` | Ouvre paramètres GPS |

### Code Clé

```dart
Future<Position> getCurrentLocation() async {
  try {
    // 1. Vérifier si GPS activé
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS désactivé');
    }

    // 2. Vérifier permissions
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission refusée');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission refusée définitivement');
    }

    // 3. Obtenir position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 30),
    );

    debugPrint('Position: ${position.latitude}, ${position.longitude}');
    return position;
  } catch (e) {
    throw Exception('Erreur de localisation: $e');
  }
}
```

### Gestion des Permissions

```dart
// Vérifier si permission accordée
Future<bool> hasPermission() async {
  final permission = await Geolocator.checkPermission();
  return permission == LocationPermission.whileInUse ||
         permission == LocationPermission.always;
}

// Ouvrir paramètres app
Future<void> openAppSettings() async {
  await Geolocator.openAppSettings();
}
```

---

## 🗺️ 4. OSMService - Géocodage

**Fichier :** `lib/core/services/osm_service.dart`

### API Utilisée

**Nominatim (OpenStreetMap)** - Gratuit, sans clé API

```
GET https://nominatim.openstreetmap.org/reverse
Parameters:
  - format: json
  - lat: {latitude}
  - lon: {longitude}
  - zoom: 12 (précision ville)
  - addressdetails: 1
  - accept-language: fr
```

### Méthodes Principales

#### 1. Obtenir ville depuis coordonnées

```dart
Future<String> getCity(double lat, double lon) async {
  final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse').replace(
    queryParameters: {
      'format': 'json',
      'lat': lat.toString(),
      'lon': lon.toString(),
      'zoom': '12',
      'addressdetails': '1',
      'accept-language': 'fr',
    },
  );

  final response = await http.get(uri, headers: {'User-Agent': 'salat-app'});

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>?;

    if (address != null) {
      // Priorité champs pour Maroc
      final city = address['city'];
      final municipality = address['municipality'];
      final town = address['town'];
      final village = address['village'];
      final country = address['country'];

      String cityName;
      if (country == 'Maroc' || country == 'Morocco') {
        cityName = city ?? municipality ?? town ?? village ?? 'Maroc';
      } else {
        cityName = city ?? municipality ?? town ?? 'Unknown';
      }

      // Vérifier si c'est vraiment Casablanca
      if (cityName == 'Casablanca') {
        final distance = _calculateDistance(lat, lon, 33.5731, -7.5898);
        if (distance > 50) {
          cityName = address['suburb'] ?? town ?? 'Maroc';
        }
      }

      return cityName;
    }
  }

  return 'Unknown';
}
```

#### 2. Recherche de villes par nom

```dart
Future<List<Map<String, dynamic>>> searchCities(String query) async {
  if (query.length < 3) return [];

  final uri = Uri.parse('https://nominatim.openstreetmap.org/search').replace(
    queryParameters: {
      'format': 'json',
      'q': query,
      'limit': '15',
      'addressdetails': '1',
    },
  );

  final response = await http.get(uri, headers: {'User-Agent': 'salat-app'});

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List<dynamic>;
    
    return data
        .where((item) {
          final type = item['type'] as String?;
          final address = item['address'] as Map<String, dynamic>?;
          final city = address?['city'] ?? address?['town'] ?? address?['village'];
          
          return (type == 'city' || type == 'town' || type == 'village') 
              && city != null;
        })
        .take(15)
        .map((item) => item as Map<String, dynamic>)
        .toList();
  }

  return [];
}
```

#### 3. Calcul de distance (Haversine)

```dart
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371; // km
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  
  final a = math.sin(dLat) * math.sin(dLat) +
            (_toRadians(lat1) * _toRadians(lat2)) * 
            math.sin(dLon) * math.sin(dLon);
  
  final c = 2 * math.asin(math.sqrt(a));
  return earthRadius * c;
}

double _toRadians(double degrees) => degrees * (math.pi / 180.0);
```

---

## 🏠 5. HomeController - Gestion Ville

**Fichier :** `lib/modules/home/controller/home_controller.dart`

### Cycle de Vie

```dart
@override
void onInit() {
  super.onInit();
  _startCountdown();
  loadData(); // Charge ville + prières
}
```

### Méthode loadData()

```dart
Future<void> loadData() async {
  isLoading = true;
  update();

  try {
    if (hiveService.hasCachedLocation()) {
      // Mode hors-ligne : charge depuis cache
      _loadFromCache();
      isLoading = false;
      update();
    } else {
      // Premier lancement : GPS + API
      await _fetchLocationData();
    }

    _updateDates();
    update();
  } catch (e) {
    // Fallback sur cache si erreur
    if (hiveService.hasCachedLocation()) {
      _loadFromCache();
    }
    city = "Location error";
    isLoading = false;
    update();
  }
}
```

### Détection GPS Manuelle

```dart
Future<void> useCurrentLocation() async {
  try {
    isUpdatingLocation = true;
    update();

    // 1. Position GPS
    final position = await locationService.getCurrentLocation();
    final lat = position.latitude;
    final lng = position.longitude;

    // 2. Ville via OSM
    final cityname = await osmService.getCity(lat, lng);

    // 3. Sauvegarde cache
    await hiveService.saveLocationData(
      latitude: lat,
      longitude: lng,
      city: cityname,
    );

    // 4. Mise à jour UI
    city = cityname;
    _recalculatePrayerTimes();
    _updateDates();
    update();

    Get.snackbar(
      'Position actuelle',
      'Ville détectée: $cityname',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    Get.snackbar(
      'Erreur',
      'Impossible de récupérer position',
      backgroundColor: Colors.red,
    );
  }
}
```

### Recherche de Ville

```dart
Future<void> searchCity(String query) async {
  if (query.length < 3) {
    searchResults.clear();
    return;
  }

  isSearching = true;
  searchQuery = query;

  final results = await osmService.searchCities(query);
  searchResults = results;
  update();

  isSearching = false;
  update();
}

Future<void> selectCity(Map<String, dynamic> result) async {
  final lat = double.parse(result['lat']);
  final lon = double.parse(result['lon']);
  final displayName = result['display_name'] as String;

  // Extraire nom ville
  final address = result['address'] as Map<String, dynamic>?;
  String cityName = address?['city'] ?? 
                    address?['town'] ?? 
                    displayName.split(',').first;

  // Sauvegarder
  await hiveService.saveLocationData(
    latitude: lat,
    longitude: lon,
    city: cityName,
  );

  city = cityName;
  _recalculatePrayerTimes();
  update();

  Get.back(); // Fermer dialog
}
```

---

## 💾 6. HiveService - Cache Local

**Fichier :** `lib/core/services/hive_service.dart`

### Sauvegarde Position

```dart
Future<void> saveLocationData({
  required double latitude,
  required double longitude,
  required String city,
}) async {
  final box = await Hive.openBox('location_cache');
  await box.put('latitude', latitude);
  await box.put('longitude', longitude);
  await box.put('city', city);
  await box.put('timestamp', DateTime.now().toIso8601String());
}
```

### Lecture Cache

```dart
bool hasCachedLocation() {
  final box = Hive.box('location_cache');
  return box.containsKey('latitude') && 
         box.containsKey('longitude') && 
         box.containsKey('city');
}

double? getCachedLatitude() {
  return Hive.box('location_cache').get('latitude');
}

double? getCachedLongitude() {
  return Hive.box('location_cache').get('longitude');
}

String? getCachedCity() {
  return Hive.box('location_cache').get('city');
}
```

### Effacer Cache

```dart
Future<void> clearLocationData() async {
  final box = await Hive.openBox('location_cache');
  await box.clear();
}
```

---

## 🎨 7. UI Widgets

### CityWidget - Affichage Ville

**Fichier :** `lib/modules/home/widgets/city_widget.dart`

```dart
class CityWidget extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (ctrl) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              // Icône localisation
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.gradientStart.withValues(alpha: 0.18),
                    AppColors.gradientEnd.withValues(alpha: 0.10),
                  ]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.location_on_rounded, 
                  color: AppColors.primary, size: 18),
              ),
              SizedBox(width: 10),
              
              // Ville + cache age
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ctrl.city, 
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text(ctrl.getCacheAge(),
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              
              // Bouton Changer
              GestureDetector(
                onTap: () => _showCitySearchDialog(context),
                child: Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_location_alt_outlined, 
                        color: AppColors.primary, size: 14),
                      SizedBox(width: 4),
                      Text('Changer', 
                        style: TextStyle(fontSize: 10, color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
              
              // Bouton GPS
              GestureDetector(
                onTap: ctrl.isUpdatingLocation ? null : () => _useCurrentLocation(context),
                child: Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(
                      alpha: ctrl.isUpdatingLocation ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: ctrl.isUpdatingLocation
                    ? SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.gps_fixed_rounded, 
                        color: AppColors.accent, size: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Dialog Recherche Ville

```dart
void _showCitySearchDialog(BuildContext context) {
  Get.dialog(
    StatefulBuilder(
      builder: (context, setDialogState) {
        return Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 24),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barre recherche
                Row(
                  children: [
                    Icon(Icons.search, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          ctrl.searchCity(value);
                          setDialogState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Rechercher une ville...',
                          border: InputBorder.none,
                        ),
                        autofocus: true,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                Divider(height: 24),
                
                // Résultats
                if (ctrl.isSearching)
                  CircularProgressIndicator()
                else if (ctrl.searchResults.isEmpty && ctrl.searchQuery.isNotEmpty)
                  Text('Aucune ville trouvée')
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: ctrl.searchResults.length,
                      itemBuilder: (context, index) {
                        final result = ctrl.searchResults[index];
                        return ListTile(
                          leading: Icon(Icons.location_on, color: AppColors.primary),
                          title: Text(result['display_name'] as String),
                          onTap: () {
                            ctrl.selectCity(result);
                            Get.back();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
```

---

## ⚙️ 8. Configuration Plates-formes

### Android

**Fichier :** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
    <!-- Permissions de localisation -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <!-- Feature GPS (optionnel pour tablettes sans GPS) -->
    <uses-feature android:name="android.hardware.location.gps" android:required="false"/>
    
    <application>
        <!-- Votre activité principale -->
    </application>
</manifest>
```

### iOS

**Fichier :** `ios/Runner/Info.plist`

```xml
<dict>
    <!-- Description permission localisation -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Cette application a besoin de votre position pour afficher les horaires de prière précis</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Cette application utilise votre position pour calculer la direction de la Qibla</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Votre position est utilisée pour afficher les horaires de prière et la Qibla</string>
</dict>
```

---

## 🎯 9. Cas d'Usage SALAT

### 1. Trouver Mosquée la Plus Proche

```dart
// Obtenir position actuelle
final position = await locationService.getCurrentLocation();

// Recherche mosquées nearby
final mosques = await osmService.searchNearby(
  lat: position.latitude,
  lon: position.longitude,
  query: 'mosque',
  radius: 5000, // 5km
);
```

### 2. Enregistrer Sa Maison

```dart
// Via bouton "Changer" → Recherche manuelle
await ctrl.selectCity({
  'lat': '33.8935',
  'lon': '-5.5473',
  'display_name': 'Meknès, Maroc',
  'address': {'city': 'Meknès'},
});

// Sauvegarde automatique dans Hive
```

### 3. Calculer Direction Qibla

```dart
// Récupérer coordonnées depuis cache
final lat = hiveService.getCachedLatitude();
final lng = hiveService.getCachedLongitude();

// Calculer Qibla
final qiblaDirection = Qibla.qibla(Coordinates(lat, lng));
```

### 4. Heures de Prière Personnalisées

```dart
// Calcul basés sur coordonnées GPS
final prayerTimes = prayerService.calculate(
  date: DateTime.now(),
  coordinates: Coordinates(lat, lng),
  calculationParameters: CalculationMethodParameters.morocco(),
);
```

---

## 🔧 10. Dépannage

### Problème : Ville toujours "Casablanca"

**Cause :** Émulateur configuré avec coordonnées de Casablanca

**Solution :**
```dart
// Option 1 : Changer coordonnées émulateur
// Android Emulator: Extended controls → Location → Meknès (33.8935, -5.5473)

// Option 2 : Utiliser bouton "Changer"
// Rechercher "Meknes" manuellement

// Option 3 : Effacer cache
Get.find<HiveService>().clearLocationData();
// Hot restart
```

### Problème : Dialog en boucle infinie

**Cause :** Détection automatique qui se relance

**Solution :**
```dart
// Supprimer détection automatique dans loadData()
// Utiliser uniquement bouton GPS manuel
```

### Problème : Permission refusée

**Solution :**
```dart
// Afficher dialog avec bouton vers paramètres
Get.snackbar(
  'Permission requise',
  'Autorisez l\'accès au GPS',
  mainButton: TextButton(
    onPressed: () => locationService.openAppSettings(),
    child: Text('Ouvrir Réglages'),
  ),
);
```

### Problème : API OSM lente

**Solution :**
```dart
// Augmenter timeout
final position = await Geolocator.getCurrentPosition(
  timeLimit: Duration(seconds: 30), // au lieu de 10
);

// Utiliser cache Hive en priorité
if (hiveService.hasCachedLocation()) {
  _loadFromCache(); // Instantané
}
```

---

## 📞 Support

Pour toute question ou problème :

1. Vérifier logs console (`debugPrint`)
2. Consulter cette documentation
3. Tester avec coordonnées manuelles (bouton "Changer")

---

**Dernière mise à jour :** Mars 2026  
**Version :** 1.0.0  
**Application :** SALAT - Horaires de prière & Qibla
