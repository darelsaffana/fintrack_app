import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLight = prefs.getBool('is_light_mode') ?? false;
      _themeMode = isLight ? ThemeMode.light : ThemeMode.dark;
      AppColors.isDark = _themeMode == ThemeMode.dark;
      notifyListeners();
    } catch (_) {
      // Fallback if shared preferences fails
      AppColors.isDark = true;
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    AppColors.isDark = _themeMode == ThemeMode.dark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_light_mode', _themeMode == ThemeMode.light);
    } catch (_) {}
  }
}
