import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';

class ThemeController extends GetxController {
  late StorageService _storageService;

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _storageService = Get.find<StorageService>();
    _loadTheme();
  }

  void _loadTheme() {
    isDarkMode.value = _storageService.getSetting('dark_mode', false);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _storageService.saveSetting('dark_mode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    update();
  }

  void setDarkMode(bool value) {
    isDarkMode.value = value;
    _storageService.saveSetting('dark_mode', value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    update();
  }
}
