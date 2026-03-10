import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class InitController extends GetxController {
  late GetStorage _storage;
  late Dio _dio;
  bool _isInitialized = false;
  bool _isInitializing = false;

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;

  // Default reciters fallback
  final List<Map<String, dynamic>> _defaultReciters = [
    {
      'identifier': 'ar.alafasy',
      'englishName': 'Mishary Alafasy',
      'name': 'مشاري العفاسي',
      'style': 'murattal',
      'baseUrl': 'https://server8.mp3quran.net/afs/',
    },
    {
      'identifier': 'ar.husary',
      'englishName': 'Mahmoud Khalil Al-Husary',
      'name': 'محمود خليل الحصري',
      'style': 'murattal',
      'baseUrl': 'https://server8.mp3quran.net/husary/',
    },
    {
      'identifier': 'ar.abdulbasitmurattal',
      'englishName': 'Abdul Basit (Murattal)',
      'name': 'عبد الباسط عبد الصمد',
      'style': 'murattal',
      'baseUrl': 'https://server8.mp3quran.net/abasit/',
    },
    {
      'identifier': 'ar.sudais',
      'englishName': 'Abdurrahman Al-Sudais',
      'name': 'عبد الرحمن السديس',
      'style': 'murattal',
      'baseUrl': 'https://server8.mp3quran.net/sudais/',
    },
    {
      'identifier': 'ar.minshawi',
      'englishName': 'Mohamed Siddiq El-Minshawi',
      'name': 'محمد صديق المنشاوي',
      'style': 'murattal',
      'baseUrl': 'https://server10.mp3quran.net/minsh/',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _storage = GetStorage();
    _dio = Dio();
  }

  Future<void> initializeApp() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;
    update();

    try {
      // Check if already initialized
      final wasInitialized = _storage.read('app_initialized') ?? false;

      if (!wasInitialized) {
        debugPrint('🚀 First launch - fetching reciters...');
        await _fetchAndCacheReciters();
        await _storage.write('app_initialized', true);
        debugPrint('✅ App initialized');
      } else {
        debugPrint('✅ App was already initialized');
      }

      _isInitialized = true;
      _isInitializing = false;
      update();
    } catch (e) {
      debugPrint('❌ Initialization error: $e');
      // Still mark as initialized with fallback data
      await _saveDefaultReciters();
      await _storage.write('app_initialized', true);
      _isInitialized = true;
      _isInitializing = false;
      update();
    }
  }

  Future<void> _fetchAndCacheReciters() async {
    try {
      final response = await _dio.get(
        'https://api.alquran.cloud/v1/edition?format=audio&language=ar',
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200 && data['data'] != null) {
          final List<dynamic> editions = data['data'];
          final reciterList = <Map<String, dynamic>>[];

          for (var edition in editions) {
            final identifier = edition['identifier'] as String? ?? '';
            final name = edition['name'] as String? ?? '';
            final englishName = edition['englishName'] as String? ?? '';
            final lang = edition['language'] as String? ?? '';
            final type = edition['type'] as String? ?? '';
            final format = edition['format'] as String? ?? '';

            // Filter: Arabic audio only
            if (lang != 'ar' || type != 'versebyverse' || format != 'audio') {
              continue;
            }

            // Extract base URL
            String baseUrl = '';
            final url = edition['url'] as String?;
            if (url != null && url.isNotEmpty) {
              baseUrl = url;
            }

            reciterList.add({
              'identifier': identifier,
              'englishName': englishName.isNotEmpty ? englishName : name,
              'name': name,
              'style': 'murattal',
              'baseUrl': baseUrl,
            });
          }

          // Add popular reciters if not in API
          for (var defaultReciter in _defaultReciters) {
            if (!reciterList.any((r) => r['identifier'] == defaultReciter['identifier'])) {
              reciterList.add(defaultReciter);
            }
          }

          // Sort by english name
          reciterList.sort((a, b) => 
            (a['englishName'] as String).compareTo(b['englishName'] as String));

          // Save to storage
          await _storage.write('reciters_cache', jsonEncode(reciterList));
          debugPrint('✅ Cached ${reciterList.length} reciters');
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching reciters: $e');
      // Save default reciters as fallback
      await _saveDefaultReciters();
    }
  }

  Future<void> _saveDefaultReciters() async {
    await _storage.write('reciters_cache', jsonEncode(_defaultReciters));
    debugPrint('✅ Saved ${_defaultReciters.length} default reciters');
  }

  Future<void> refreshReciters() async {
    debugPrint('🔄 Refreshing reciters...');
    await _fetchAndCacheReciters();
    update();
  }
}
