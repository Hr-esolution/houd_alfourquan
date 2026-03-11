import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/language_controller.dart';
import '../models/ayah_model.dart';

/// Repository for accessing Quran data from local JSON files
/// Uses separate files for each language (quran_ar.json, quran_fr.json, quran_en.json)
class QuranRepository extends GetxService {
  // Cache for loaded surahs
  final Map<int, List<AyahModel>> _surahCache = {};
  
  // Cache for surah names
  final Map<int, String> _surahNames = {};
  
  // Cached Quran data by language
  final Map<String, List<Map<String, dynamic>>> _quranDataByLang = {};
  
  // Total surahs count
  static const int totalSurahs = 114;
  
  // Total ayahs count
  static const int totalAyahs = 6236;
  
  // Loaded flag
  bool _isLoaded = false;

  /// Check if repository is loaded
  bool get isLoaded => _isLoaded;

  @override
  void onInit() {
    super.onInit();
    _preloadSurahNames();
  }

  /// Preload surah names for quick access
  Future<void> _preloadSurahNames() async {
    try {
      // Load Arabic data for names
      final jsonString = await rootBundle.loadString('assets/data/quran_ar.json');
      final data = json.decode(jsonString) as List<dynamic>;
      
      for (var i = 0; i < data.length; i++) {
        final surah = data[i] as Map<String, dynamic>;
        final number = surah['number'] as int;
        final name = surah['name_arabic'] as String;
        _surahNames[number] = name;
      }
      
      _isLoaded = true;
      debugPrint('✅ Quran Repository loaded: ${_surahNames.length} surahs');
    } catch (e) {
      debugPrint('❌ Error loading Quran: $e');
      _isLoaded = false;
    }
  }

  /// Get a specific surah by number
  Future<List<AyahModel>?> getSurah(int surahNumber) async {
    if (surahNumber < 1 || surahNumber > totalSurahs) {
      debugPrint('❌ Invalid surah number: $surahNumber');
      return null;
    }

    // Return from cache if available
    if (_surahCache.containsKey(surahNumber)) {
      debugPrint('📖 Cache hit: Surah $surahNumber');
      return _surahCache[surahNumber];
    }

    // Load from JSON
    try {
      final langCode = Get.find<LanguageController>().currentLang;
      await _loadQuranData(langCode);
      
      final arabicData = _quranDataByLang['ar'];
      final langData = _quranDataByLang[langCode];
      
      if (arabicData == null || langData == null) {
        debugPrint('❌ No Quran data loaded for language: $langCode');
        return null;
      }
      
      // Find the surah in both datasets
      final arabicSurah = _findSurah(arabicData, surahNumber);
      final langSurah = _findSurah(langData, surahNumber);
      
      if (arabicSurah == null || langSurah == null) {
        debugPrint('❌ Surah $surahNumber not found');
        return null;
      }
      
      // Parse and combine ayahs
      final ayahs = _combineAyahs(arabicSurah, langSurah, surahNumber);
      
      // Cache it
      _surahCache[surahNumber] = ayahs;
      debugPrint('📖 Loaded Surah $surahNumber: ${ayahs.length} ayahs');
      
      return ayahs;
    } catch (e) {
      debugPrint('❌ Error loading Surah $surahNumber: $e');
      return null;
    }
  }

  /// Find surah in data list
  Map<String, dynamic>? _findSurah(List<Map<String, dynamic>> data, int surahNumber) {
    try {
      // Try by 'id' first, then by 'number'
      return data.firstWhere(
        (s) => (s['id'] ?? s['number']) == surahNumber,
      );
    } catch (_) {
      return null;
    }
  }

  /// Combine Arabic and translation ayahs
  List<AyahModel> _combineAyahs(
    Map<String, dynamic> arabicSurah,
    Map<String, dynamic> langSurah,
    int surahNumber,
  ) {
    final arabicVerses = arabicSurah['verses'] as List<dynamic>;
    final langVerses = langSurah['verses'] as List<dynamic>;
    
    final List<AyahModel> ayahs = [];
    final langCode = Get.find<LanguageController>().currentLang;
    
    for (var i = 0; i < arabicVerses.length && i < langVerses.length; i++) {
      final arabicVerse = arabicVerses[i] as Map<String, dynamic>;
      final langVerse = langVerses[i] as Map<String, dynamic>;
      
      // Ayah number is 1-indexed in the array
      final ayahNumber = i + 1;
      
      ayahs.add(AyahModel(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        textAr: arabicVerse['text'] as String,
        textFr: langCode == 'fr' ? (langVerse['text'] as String) : '',
        textEn: langCode == 'en' ? (langVerse['text'] as String) : '',
      ));
    }
    
    return ayahs;
  }

  /// Load Quran data for a specific language
  Future<void> _loadQuranData(String langCode) async {
    // Check if already loaded
    if (_quranDataByLang.containsKey(langCode)) {
      return;
    }
    
    try {
      // Load Arabic text
      if (!_quranDataByLang.containsKey('ar')) {
        final arJson = await rootBundle.loadString('assets/data/quran_ar.json');
        _quranDataByLang['ar'] = (json.decode(arJson) as List<dynamic>)
            .map((s) => s as Map<String, dynamic>)
            .toList();
        debugPrint('✅ Loaded Arabic Quran: ${_quranDataByLang['ar']!.length} surahs');
      }
      
      // Load translation
      final langFile = 'assets/data/quran_$langCode.json';
      final langJson = await rootBundle.loadString(langFile);
      _quranDataByLang[langCode] = (json.decode(langJson) as List<dynamic>)
          .map((s) => s as Map<String, dynamic>)
          .toList();
      debugPrint('✅ Loaded $langCode Quran: ${_quranDataByLang[langCode]!.length} surahs');
    } catch (e) {
      debugPrint('❌ Error loading Quran data for $langCode: $e');
      rethrow;
    }
  }

  /// Get a specific ayah by surah and ayah number
  Future<AyahModel?> getAyah(int surahNumber, int ayahNumber) async {
    final surah = await getSurah(surahNumber);
    if (surah == null) return null;
    
    try {
      return surah.firstWhere((ayah) => ayah.ayahNumber == ayahNumber);
    } catch (_) {
      return null;
    }
  }

  /// Get a range of ayahs starting from a position
  /// Returns [count] ayahs starting from [startSurah]:[startAyah]
  Future<List<AyahModel>> getAyahRange({
    required int startSurah,
    required int startAyah,
    required int count,
  }) async {
    final List<AyahModel> result = [];
    var remaining = count;
    
    var currentSurah = startSurah;
    var currentAyah = startAyah;
    
    while (remaining > 0 && currentSurah <= totalSurahs) {
      final surah = await getSurah(currentSurah);
      if (surah == null) break;
      
      // Get ayahs from current position to end of surah (or remaining count)
      final ayahsToTake = surah
          .where((ayah) => ayah.ayahNumber >= currentAyah)
          .take(remaining)
          .toList();
      
      result.addAll(ayahsToTake);
      remaining -= ayahsToTake.length;
      
      // Move to next surah
      currentSurah++;
      currentAyah = 1; // Start from first ayah of next surah
    }
    
    debugPrint('📖 Got ${result.length} ayahs from $startSurah:$startAyah');
    return result;
  }

  /// Get surah name by number
  String getSurahName(int surahNumber) {
    return _surahNames[surahNumber] ?? 'Surah $surahNumber';
  }

  /// Get total ayah count for a surah
  Future<int> getSurahAyahCount(int surahNumber) async {
    final surah = await getSurah(surahNumber);
    return surah?.length ?? 0;
  }

  /// Check if a position is valid
  Future<bool> isValidPosition(int surahNumber, int ayahNumber) async {
    if (surahNumber < 1 || surahNumber > totalSurahs) return false;
    if (ayahNumber < 1) return false;
    
    final count = await getSurahAyahCount(surahNumber);
    return ayahNumber <= count;
  }

  /// Check if user reached end of Quran
  bool isEndOfQuran(int surahNumber, int ayahNumber) {
    return surahNumber >= totalSurahs && ayahNumber >= 6; // Last ayah is 114:6
  }

  /// Get next position
  Future<Map<String, int>> getNextPosition(int surahNumber, int ayahNumber) async {
    final surahCount = await getSurahAyahCount(surahNumber);
    
    if (ayahNumber >= surahCount) {
      // End of surah, move to next
      if (surahNumber >= totalSurahs) {
        // End of Quran
        return {'surah': totalSurahs, 'ayah': 6};
      }
      return {'surah': surahNumber + 1, 'ayah': 1};
    }
    
    return {'surah': surahNumber, 'ayah': ayahNumber + 1};
  }

  /// Clear cache (for memory management)
  void clearCache() {
    _surahCache.clear();
    _quranDataByLang.clear();
    debugPrint('🗑️ Quran cache cleared');
  }
}
