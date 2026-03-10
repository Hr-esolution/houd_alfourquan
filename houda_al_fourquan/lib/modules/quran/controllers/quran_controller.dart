import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class QuranController extends GetxController {
  List<Map<String, dynamic>> _quranAr = [];
  List<Map<String, dynamic>> _quranFr = [];
  List<Map<String, dynamic>> _quranEn = [];
  List<Map<String, dynamic>> _surahs = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get quranAr => _quranAr;
  List<Map<String, dynamic>> get quranFr => _quranFr;
  List<Map<String, dynamic>> get quranEn => _quranEn;
  List<Map<String, dynamic>> get surahs => _surahs;
  bool get isLoading => _isLoading;

  @override
  void onInit() {
    super.onInit();
    _loadQuranData();
  }

  Future<void> _loadQuranData() async {
    try {
      // Load chapters index
      final surahsJson = await rootBundle.loadString('assets/data/surahs.json');
      _surahs = List<Map<String, dynamic>>.from(jsonDecode(surahsJson));

      // Load Arabic text
      final quranArJson = await rootBundle.loadString('assets/data/quran_ar.json');
      _quranAr = List<Map<String, dynamic>>.from(jsonDecode(quranArJson));

      // Try to load translations (optional)
      try {
        final quranFrJson = await rootBundle.loadString('assets/data/quran_fr.json');
        _quranFr = List<Map<String, dynamic>>.from(jsonDecode(quranFrJson));
      } catch (e) {
        _quranFr = [];
      }

      try {
        final quranEnJson = await rootBundle.loadString('assets/data/quran_en.json');
        _quranEn = List<Map<String, dynamic>>.from(jsonDecode(quranEnJson));
      } catch (e) {
        _quranEn = [];
      }

      _isLoading = false;
      update();
      debugPrint('✅ Quran data loaded: ${_surahs.length} surahs');
    } catch (e) {
      debugPrint('❌ Error loading Quran data: $e');
      _isLoading = false;
      update();
    }
  }

  String getSurahName(int surahNumber) {
    if (surahNumber < 1 || surahNumber > _surahs.length) return '';
    return _surahs[surahNumber - 1]['name'] ?? '';
  }

  String getSurahNameEnglish(int surahNumber) {
    if (surahNumber < 1 || surahNumber > _surahs.length) return '';
    return _surahs[surahNumber - 1]['englishName'] ?? '';
  }

  int getSurahAyahCount(int surahNumber) {
    if (surahNumber < 1 || surahNumber > _surahs.length) return 0;
    return _surahs[surahNumber - 1]['ayahCount'] ?? 0;
  }

  String getAyahText(int surahNumber, int ayahNumber) {
    if (surahNumber < 1 || surahNumber > _quranAr.length) return '';
    final surahData = _quranAr[surahNumber - 1];
    final ayahs = surahData['ayahs'] as List?;
    if (ayahs == null || ayahNumber < 1 || ayahNumber > ayahs.length) return '';
    return ayahs[ayahNumber - 1]['text'] ?? '';
  }
}
