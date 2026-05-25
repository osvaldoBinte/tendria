import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:tendria/framework/preferences_service.dart';  

class ThemeController extends GetxController {
  final _prefs = PreferencesUser();
  final RxBool isDarkMode = false.obs;

  static const String _key = 'isDarkMode';

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

Future<void> _loadTheme() async {
  final saved = await _prefs.loadPrefs(type: bool, key: _key);
  isDarkMode.value = saved ?? true;  
}
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _prefs.savePrefs(type: bool, key: _key, value: isDarkMode.value);
    Get.changeThemeMode(
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }
}