import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/controllers/language_controller.dart';
import 'model/tasbih_item.dart';

class TasbihController extends GetxController {
  // Selected tasbih item
  Rx<TasbihItem?> selectedTasbih = Rx<TasbihItem?>(null);

  // Counter for current tasbih
  RxInt counter = 0.obs;

  // Selected category
  Rx<TasbihCategory> selectedCategory = TasbihCategory.daily.obs;

  // Observable map for all tasbih counts (for real-time updates)
  RxMap<String, int> allCounts = <String, int>{}.obs;

  // Box for storing counts
  late Box<dynamic> _tasbihBox;

  // Initialization flag
  RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  /// Initialize Hive storage
  Future<void> _initHive() async {
    try {
      _tasbihBox = await Hive.openBox('tasbih_counts');

      // Load all existing counts into observable map
      _loadAllCounts();

      // Select first tasbih by default
      if (TasbihPresets.daily.isNotEmpty) {
        selectedTasbih.value = TasbihPresets.daily.first;
        counter.value = getTasbihCount(selectedTasbih.value!.id);
      }

      isInitialized.value = true;
      update();
    } catch (e) {
      if (presets.isNotEmpty) {
        selectedTasbih.value = presets.first;
      }
      isInitialized.value = true;
      update();
    }
  }

  /// Load all counts from Hive into observable map
  void _loadAllCounts() {
    allCounts.clear();
    for (var key in _tasbihBox.keys) {
      if (key is String) {
        allCounts[key] = _tasbihBox.get(key) as int? ?? 0;
      }
    }
    update();
  }

  /// Get presets for current category
  List<TasbihItem> get presets {
    return selectedCategory.value == TasbihCategory.daily
        ? TasbihPresets.daily
        : TasbihPresets.afterPrayer;
  }

  /// Select a category
  void selectCategory(TasbihCategory category) {
    selectedCategory.value = category;
    // Select first tasbih in new category
    if (presets.isNotEmpty) {
      selectedTasbih.value = presets.first;
      counter.value = getTasbihCount(selectedTasbih.value!.id);
    }
    update();
  }

  /// Select a tasbih preset
  void selectTasbih(TasbihItem tasbih) {
    selectedTasbih.value = tasbih;
    counter.value = getTasbihCount(tasbih.id);
    update();
  }

  /// Get count for a specific tasbih by ID (from observable map)
  int getTasbihCount(String tasbihId) {
    return allCounts[tasbihId] ?? 0;
  }

  /// Save counter to Hive
  Future<void> _saveCounter(String id, int value) async {
    if (!_tasbihBox.isOpen) return;
    await _tasbihBox.put(id, value);
  }

  /// Increment counter
  Future<void> increment() async {
    if (!isInitialized.value || selectedTasbih.value == null) return;

    // Vibration feedback
    HapticFeedback.lightImpact();

    // Increment
    counter.value++;

    // Update observable map (triggers UI update in list)
    allCounts[selectedTasbih.value!.id] = counter.value;

    // Save to Hive
    await _saveCounter(selectedTasbih.value!.id, counter.value);

    update();

    // Check if target reached
    if (counter.value >= selectedTasbih.value!.targetCount) {
      // Completion vibration pattern
      _vibrationPattern();

      // Show snackbar
      Get.snackbar(
        'Masha\'Allah !'.trx,
        '${'Vous avez complété'.trx} ${selectedTasbih.value!.translatedText}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  /// Vibration pattern when target is reached
  void _vibrationPattern() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.heavyImpact();
      });
    });
  }

  /// Reset counter for current tasbih
  Future<void> reset() async {
    if (selectedTasbih.value == null) return;

    HapticFeedback.mediumImpact();
    counter.value = 0;
    allCounts[selectedTasbih.value!.id] = 0;
    await _saveCounter(selectedTasbih.value!.id, 0);
    update();
  }

  /// Reset all tasbih counters
  Future<void> resetAll() async {
    HapticFeedback.mediumImpact();
    await _tasbihBox.clear();
    allCounts.clear();
    counter.value = 0;
    update();

    Get.snackbar(
      'Réinitialisé'.trx,
      'Tous les compteurs ont été réinitialisés'.trx,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Get progress percentage
  double get progress {
    if (selectedTasbih.value == null) return 0.0;
    final target = selectedTasbih.value!.targetCount;
    return (counter.value / target).clamp(0.0, 1.0);
  }

  /// Get remaining count
  int get remaining {
    if (selectedTasbih.value == null) return 0;
    final target = selectedTasbih.value!.targetCount;
    return (target - counter.value).clamp(0, target);
  }

  /// Check if target is reached
  bool get isTargetReached {
    if (selectedTasbih.value == null) return false;
    return counter.value >= selectedTasbih.value!.targetCount;
  }
}
