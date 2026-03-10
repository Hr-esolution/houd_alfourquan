import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Setup Assets Script
/// This script downloads reciter data from AlQuran Cloud API
/// and saves it to assets/data/reciters.json
///
/// Usage: dart scripts/setup_assets.dart
void main() async {
  debugPrint('🚀 Starting setup assets script...');

  // Create assets/data directory if not exists
  final dataDir = Directory('assets/data');
  if (!await dataDir.exists()) {
    await dataDir.create(recursive: true);
    debugPrint('📁 Created assets/data directory');
  }

  // Download reciters from AlQuran Cloud API
  debugPrint('📡 Fetching reciters from AlQuran Cloud API...');
  await downloadReciters();

  debugPrint('✅ Setup complete!');
}

Future<void> downloadReciters() async {
  try {
    final response = await http.get(
      Uri.parse('https://api.alquran.cloud/v1/edition?format=audio&language=ar'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 200 && data['data'] != null) {
        final List<dynamic> editions = data['data'];
        final reciterMap = <String, Map<String, dynamic>>{};

        // Filter and process editions
        for (var edition in editions) {
          final identifier = edition['identifier'] as String? ?? '';
          final name = edition['name'] as String? ?? '';
          final lang = edition['language'] as String? ?? '';
          final type = edition['type'] as String? ?? '';

          // Filter: Arabic audio only
          if (lang != 'ar' || type != 'versebyverse') continue;

          // Extract reciter ID from identifier
          final parts = identifier.split('/');
          final reciterId = parts.isNotEmpty ? parts[0] : identifier;

          if (!reciterMap.containsKey(reciterId)) {
            reciterMap[reciterId] = {
              'id': reciterId,
              'name_ar': name,
              'name_fr': name,
              'style': 'murattal',
              'base_url': 'https://cdn.islamic.network/quran/audio/128/$identifier/',
              'cover_image': '',
              'total_size_mb': 0.0,
            };
          }
        }

        // Add popular reciters manually
        final popularReciters = [
          {
            'id': 'mishary',
            'name_ar': 'مشاري العفاسي',
            'name_fr': 'Mishary Alafasy',
            'style': 'murattal',
            'base_url': 'https://server8.mp3quran.net/afs/',
            'cover_image': '',
            'total_size_mb': 820.0,
          },
          {
            'id': 'sudais',
            'name_ar': 'عبد الرحمن السديس',
            'name_fr': 'Abdulrahman Sudais',
            'style': 'murattal',
            'base_url': 'https://server11.mp3quran.net/sds/',
            'cover_image': '',
            'total_size_mb': 750.0,
          },
          {
            'id': 'shuraim',
            'name_ar': 'سعود الشريم',
            'name_fr': 'Saud Al-Shuraim',
            'style': 'murattal',
            'base_url': 'https://server7.mp3quran.net/shur/',
            'cover_image': '',
            'total_size_mb': 680.0,
          },
          {
            'id': 'maher',
            'name_ar': 'ماهر المعيقلي',
            'name_fr': 'Maher Al-Muaiqly',
            'style': 'murattal',
            'base_url': 'https://server13.mp3quran.net/maher/',
            'cover_image': '',
            'total_size_mb': 790.0,
          },
          {
            'id': 'ghamdi',
            'name_ar': 'سعد الغامدي',
            'name_fr': 'Saad Al-Ghamdi',
            'style': 'murattal',
            'base_url': 'https://server9.mp3quran.net/gmd/',
            'cover_image': '',
            'total_size_mb': 720.0,
          },
        ];

        for (var reciter in popularReciters) {
          if (!reciterMap.containsKey(reciter['id'])) {
            reciterMap[reciter['id'] as String] = reciter;
          }
        }

        final reciters = reciterMap.values.toList();
        reciters.sort((a, b) => (a['name_fr'] as String).compareTo(b['name_fr'] as String));

        // Save to file
        final file = File('assets/data/reciters.json');
        await file.writeAsString(JsonEncoder.withIndent('  ').convert(reciters));

        debugPrint('✅ Saved ${reciters.length} reciters to assets/data/reciters.json');
      } else {
        debugPrint('❌ API returned error: ${data['status']}');
      }
    } else {
      debugPrint('❌ Failed to fetch reciters: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('❌ Error: $e');
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
