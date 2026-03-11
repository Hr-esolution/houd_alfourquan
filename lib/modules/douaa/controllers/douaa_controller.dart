import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/dua_model.dart';

enum DuaCategory { quran, prophet }

class DouaaController extends GetxController {
  final List<DuaModel> _quranDuas = [];
  final List<DuaModel> _prophetDuas = [];
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  List<DuaModel> get quranDuas => _quranDuas;
  List<DuaModel> get prophetDuas => _prophetDuas;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadDuas();
  }

  /// Load all duas from JSON files
  Future<void> loadDuas() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      // Load Quran duas
      await _loadQuranDuas();

      // Load Prophet duas (to be implemented)
      await _loadProphetDuas();

      _isLoading.value = false;
    } catch (e) {
      _isLoading.value = false;
      _hasError.value = true;
      _errorMessage.value = 'Erreur de chargement: $e';
      Get.snackbar(
        'Erreur',
        'Impossible de charger les douas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Load Quran duas from JSON file
  Future<void> _loadQuranDuas() async {
    try {
      final jsonString = await rootBundle.loadString('assets/duas/quran_duas.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final duasList = jsonData['duas'] as List<dynamic>;

      _quranDuas.clear();
      _quranDuas.addAll(
        duasList.map((dua) => DuaModel.fromJson(dua as Map<String, dynamic>)).toList(),
      );

      debugPrint('✅ ${_quranDuas.length} Quran duas loaded');
      update();
    } catch (e) {
      debugPrint('❌ Error loading Quran duas: $e');
      rethrow;
    }
  }

  /// Load Prophet duas from JSON file
  Future<void> _loadProphetDuas() async {
    try {
      final jsonString = await rootBundle.loadString('assets/duas/prophet_duas.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final duasList = jsonData['duas'] as List<dynamic>;

      _prophetDuas.clear();
      _prophetDuas.addAll(
        duasList.map((dua) => DuaModel.fromJson(dua as Map<String, dynamic>)).toList(),
      );

      debugPrint('✅ ${_prophetDuas.length} Prophet duas loaded');
      update();
    } catch (e) {
      debugPrint('❌ Error loading Prophet duas: $e');
    }
  }

  /// Get duas by category
  List<DuaModel> getDuasByCategory(DuaCategory category) {
    switch (category) {
      case DuaCategory.quran:
        return _quranDuas;
      case DuaCategory.prophet:
        return _prophetDuas;
    }
  }

  /// Get category name
  String getCategoryName(DuaCategory category) {
    switch (category) {
      case DuaCategory.quran:
        return 'Douaa du Coran';
      case DuaCategory.prophet:
        return 'Douaa du Prophète';
    }
  }

  /// Refresh duas
  Future<void> refreshDuas() async {
    await loadDuas();
  }
}
