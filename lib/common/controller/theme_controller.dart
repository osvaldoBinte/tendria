import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:tendria/framework/preferences_service.dart';  

enum AppThemeMode { light, dark, vip }

class ThemeController extends GetxController {
  final _prefs = PreferencesUser();
  final Rx<AppThemeMode> themeMode = AppThemeMode.vip.obs;
 
  bool get isDarkMode => themeMode.value == AppThemeMode.dark;
  bool get isVipMode => themeMode.value == AppThemeMode.vip;

  static const String _key = 'appThemeMode';

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await _prefs.loadPrefs(type: int, key: _key);
    themeMode.value = (saved != null && saved < AppThemeMode.values.length)
        ? AppThemeMode.values[saved]
        : AppThemeMode.vip;
    _applyFlutterThemeMode();
  }

  void setThemeMode(AppThemeMode mode) {
    themeMode.value = mode;
    _prefs.savePrefs(type: int, key: _key, value: mode.index);
    _applyFlutterThemeMode();
  }

  void toggleTheme() {
    setThemeMode(isDarkMode ? AppThemeMode.light : AppThemeMode.dark);
  }

  void toggleVip() {
    setThemeMode(isVipMode ? AppThemeMode.dark : AppThemeMode.vip);
  }
 
  void _applyFlutterThemeMode() {
    Get.changeThemeMode(
      themeMode.value == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark,
    );
  }
}