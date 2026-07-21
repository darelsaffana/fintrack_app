import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { light, dark }

class ThemeProvider extends ChangeNotifier {
  ThemeModeOption _themeMode = ThemeModeOption.light;
  static const String _prefKey = 'theme_mode';

  ThemeMode get themeMode => switch (_themeMode) {
        ThemeModeOption.light => ThemeMode.light,
        ThemeModeOption.dark => ThemeMode.dark,
      };

  ThemeModeOption get themeModeOption => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_prefKey);
    if (savedMode != null) {
      _themeMode = switch (savedMode) {
        'light' => ThemeModeOption.light,
        'dark' => ThemeModeOption.dark,
        _ => ThemeModeOption.light,
      };
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final savedMode = switch (mode) {
      ThemeModeOption.light => 'light',
      ThemeModeOption.dark => 'dark',
    };
    await prefs.setString(_prefKey, savedMode);
  }
}
