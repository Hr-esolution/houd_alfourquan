import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';

/// Tasbih Controller using GetBuilder (NO Obx/Rx)
class TasbihController extends GetxController {
  late StorageService _storageService;

  // State
  int _count = 0;
  int _target = 33;
  String _selectedDhikr = 'SubhanAllah';
  bool _isVibrationEnabled = true;

  // Dhikr presets
  final List<Map<String, dynamic>> _dhikrPresets = [
    {
      'name': 'SubhanAllah',
      'arabic': 'سُبْحَانَ ٱللَّٰهِ',
      'reward': 'Gloire à Allah',
    },
    {
      'name': 'Alhamdulillah',
      'arabic': 'ٱلْحَمْدُ لِلَّٰهِ',
      'reward': 'Louange à Allah',
    },
    {
      'name': 'Allahu Akbar',
      'arabic': 'ٱللَّٰهُ أَكْبَرُ',
      'reward': 'Allah est le plus grand',
    },
    {
      'name': 'La ilaha illallah',
      'arabic': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      'reward': 'Il n\'y a de dieu qu\'Allah',
    },
    {
      'name': 'Astaghfirullah',
      'arabic': 'أَسْتَغْفِرُ ٱللَّٰهَ',
      'reward': 'Je demande pardon à Allah',
    },
    {
      'name': 'La hawla wa la quwwata',
      'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّٰهِ',
      'reward': 'Il n\'y a de force ni de puissance qu\'en Allah',
    },
  ];

  // History
  final List<Map<String, dynamic>> _history = [];

  // Getters
  int get count => _count;
  int get target => _target;
  String get selectedDhikr => _selectedDhikr;
  bool get isVibrationEnabled => _isVibrationEnabled;
  List<Map<String, dynamic>> get dhikrPresets => _dhikrPresets;
  List<Map<String, dynamic>> get history => _history;

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<StorageService>();
    _loadSettings();
  }

  void increment() {
    _count++;

    // Vibration feedback
    if (_isVibrationEnabled) {
      // Haptic feedback would be implemented here
    }

    // Check if target reached
    if (_count >= _target) {
      _addToHistory();
      _showTargetReached();
    }

    update();
  }

  void reset() {
    _count = 0;
    update();
  }

  void setTarget(int target) {
    _target = target;
    _storageService.saveSetting('tasbih_target', target);
    update();
  }

  void setSelectedDhikr(String dhikr) {
    _selectedDhikr = dhikr;
    _storageService.saveSetting('tasbih_dhikr', dhikr);
    update();
  }

  void toggleVibration() {
    _isVibrationEnabled = !_isVibrationEnabled;
    _storageService.saveSetting('tasbih_vibration', _isVibrationEnabled);
    update();
  }

  Map<String, dynamic> getCurrentDhikr() {
    return _dhikrPresets.firstWhere(
      (d) => d['name'] == _selectedDhikr,
      orElse: () => _dhikrPresets[0],
    );
  }

  void _addToHistory() {
    _history.insert(0, {
      'dhikr': _selectedDhikr,
      'count': _target,
      'date': DateTime.now(),
    });

    // Keep only last 50 entries
    if (_history.length > 50) {
      _history.removeLast();
    }

    _storageService.saveSetting('tasbih_history', _history);
  }

  void _showTargetReached() {
    Get.snackbar(
      'MashaAllah!',
      'Target reached: $_target repetitions',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _loadSettings() {
    _target = _storageService.getSetting('tasbih_target', 33);
    _selectedDhikr = _storageService.getSetting('tasbih_dhikr', 'SubhanAllah');
    _isVibrationEnabled = _storageService.getSetting('tasbih_vibration', true);

    final savedHistory = _storageService.getSetting<List>('tasbih_history', []);
    _history.clear();
    _history.addAll(savedHistory.map((e) => e as Map<String, dynamic>));

    update();
  }

  void clearHistory() {
    _history.clear();
    _storageService.saveSetting('tasbih_history', []);
    update();

    Get.snackbar(
      'Success',
      'History cleared',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
