import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/language_controller.dart';

class ReadingController extends GetxController {
  // Scroll control
  ScrollController scrollController = ScrollController();
  Timer? _scrollTimer;

  // State
  bool isScrolling = false;
  double scrollSpeed = 1.0;
  double _pixelsPerTick = 1.0;

  // Data
  List<Map<String, dynamic>> ayahs = [];
  String currentLang = 'ar';
  List<Map<String, dynamic>> translations = [];

  @override
  void onClose() {
    _scrollTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadSurah(int surahNumber, String lang) async {
    try {
      // Stop any ongoing scroll
      stopScroll();

      // Reset state
      ayahs = [];
      translations = [];
      currentLang = lang;

      debugPrint('📖 Loading Surah $surahNumber...');

      // Get current language from LanguageController
      final langController = Get.find<LanguageController>();
      final currentLangCode = langController.currentLang;

      // Load Quran Arabic text
      final quranJson = await rootBundle.loadString('assets/data/quran_ar.json');
      final List<dynamic> data = jsonDecode(quranJson);

      debugPrint('📚 Total surahs in JSON: ${data.length}');

      if (surahNumber < 1 || surahNumber > data.length) {
        debugPrint('❌ Invalid surah number: $surahNumber');
        Get.snackbar('Error'.trx, 'Invalid surah number'.trx);
        update();
        return;
      }

      // Extract ayahs for the selected surah
      final surahData = data[surahNumber - 1] as Map<String, dynamic>;
      final verses = surahData['verses'] as List<dynamic>;

      debugPrint('📖 Surah name: ${surahData['name']}, Verses: ${verses.length}');

      ayahs = verses.map((v) {
        String arabicText = v['text_uthmani'] ?? v['text'] ?? '';
        int ayahNumber = v['id'] ?? 0;
        String ayahNumeral = _toArabicNumerals(ayahNumber);
        return {
          'id': v['id'],
          'text': arabicText,
          'number': ayahNumber,
          'number_ar': ayahNumeral,
        };
      }).toList();

      // Load translation if not Arabic
      if (currentLangCode != 'ar') {
        try {
          final translationFile = 'assets/data/quran_$currentLangCode.json';
          final translationJson = await rootBundle.loadString(translationFile);
          final List<dynamic> translationData = jsonDecode(translationJson);
          
          if (surahNumber <= translationData.length) {
            final translationSurah = translationData[surahNumber - 1] as Map<String, dynamic>;
            final translationVerses = translationSurah['verses'] as List<dynamic>;
            
            translations = translationVerses.map((v) {
              String text = v['text'] ?? '';
              // Remove HTML tags and footnotes from translation
              text = text.replaceAll(RegExp(r'<[^>]*>'), '');
              text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
              return {
                'id': v['id'],
                'text': text,
              };
            }).toList();
            
            debugPrint('✅ Loaded ${translations.length} translations');
          }
        } catch (e) {
          debugPrint('⚠️ Translation not available: $e');
          translations = [];
        }
      }

      // Debug first ayah text
      if (ayahs.isNotEmpty) {
        debugPrint('🔤 First ayah text: ${ayahs[0]['text']}');
      }

      // Reset scroll position
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }

      debugPrint('✅ Loaded Surah $surahNumber: ${ayahs.length} ayahs');
      update();
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading surah: $e');
      debugPrint('Stack trace: $stackTrace');
      Get.snackbar('Error'.trx, 'Failed to load surah'.trx);
      update();
    }
  }

  void startScroll() {
    if (_scrollTimer != null && _scrollTimer!.isActive) return;
    if (!scrollController.hasClients) return;

    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
    isScrolling = true;
    update(['scroll_controls']);
  }

  void _tick() {
    if (!scrollController.hasClients) {
      stopScroll();
      return;
    }

    final position = scrollController.position;
    
    // Check if we reached the end
    if (position.pixels >= position.maxScrollExtent - 1) {
      stopScroll();
      return;
    }

    // Calculate pixels to move based on speed
    _pixelsPerTick = scrollSpeed * 0.8;
    scrollController.jumpTo(position.pixels + _pixelsPerTick);
  }

  void stopScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    isScrolling = false;
    update(['scroll_controls']);
  }

  void toggleScroll() {
    if (isScrolling) {
      stopScroll();
    } else {
      startScroll();
    }
  }

  void setSpeed(double newSpeed) {
    scrollSpeed = newSpeed.clamp(0.5, 5.0);
    update(['scroll_controls']);
  }

  void goToBeginning() {
    stopScroll();
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  // Convert number to Arabic numerals
  String _toArabicNumerals(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'\d'),
      (match) {
        switch (match.group(0)) {
          case '0': return '٠';
          case '1': return '١';
          case '2': return '٢';
          case '3': return '٣';
          case '4': return '٤';
          case '5': return '٥';
          case '6': return '٦';
          case '7': return '٧';
          case '8': return '٨';
          case '9': return '٩';
          default: return match.group(0)!;
        }
      },
    );
  }

  // Empty method for compatibility
  void detectCurrentAyah() {
    // No-op - kept for compatibility
  }
}
